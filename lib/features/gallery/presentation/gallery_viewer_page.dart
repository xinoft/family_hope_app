import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/gallery_item.dart';
import 'widgets/gallery_video_player.dart';

/// Full-screen, swipeable media viewer. Pushed with a plain
/// [MaterialPageRoute] rather than a go_router route - it's an ephemeral
/// detail view over a specific list of items, not something that needs a
/// stable, deep-linkable URL.
class GalleryViewerPage extends StatefulWidget {
  final List<GalleryItem> items;
  final int initialIndex;

  const GalleryViewerPage({super.key, required this.items, required this.initialIndex});

  @override
  State<GalleryViewerPage> createState() => _GalleryViewerPageState();
}

class _GalleryViewerPageState extends State<GalleryViewerPage> {
  late final PageController _pageController = PageController(initialPage: widget.initialIndex);
  late int _currentIndex = widget.initialIndex;
  bool _isFullscreen = false;
  bool _isDownloading = false;

  @override
  void dispose() {
    // In case the page is popped (e.g. system back gesture) while still in
    // fullscreen - never leave the rest of the app locked to landscape or
    // with the system UI hidden.
    _restoreChrome();
    _pageController.dispose();
    super.dispose();
  }

  void _restoreChrome() {
    SystemChrome.setPreferredOrientations([]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _toggleFullscreen() {
    final goingFullscreen = !_isFullscreen;
    setState(() => _isFullscreen = goingFullscreen);
    if (goingFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      _restoreChrome();
    }
  }

  /// Fetches the item's bytes from its (external, CloudFront-hosted) URL
  /// and hands them to the OS share sheet, where "Save Image"/"Save
  /// Video" does the actual download - no photo-library permission needed
  /// on either platform this way.
  Future<void> _downloadItem(GalleryItem item) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final response = await Dio().get<List<int>>(
        item.fileUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, name: item.fileName, mimeType: item.contentType)],
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't download this item")),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, result) {
        // While fullscreen, back exits fullscreen first rather than
        // leaving the viewer entirely.
        if (!didPop && _isFullscreen) _toggleFullscreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullscreen
            ? null
            : AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  widget.items[_currentIndex].fileName,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  IconButton(
                    tooltip: 'Download',
                    onPressed: _isDownloading ? null : () => _downloadItem(widget.items[_currentIndex]),
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download_outlined),
                  ),
                ],
              ),
        body: PageView.builder(
          controller: _pageController,
          // Disabled while fullscreen so a swipe intended for video
          // controls (or just steadying a finger) doesn't flip to the
          // next item.
          physics: _isFullscreen ? const NeverScrollableScrollPhysics() : null,
          itemCount: widget.items.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            final item = widget.items[index];
            if (item.mediaType == GalleryMediaType.video) {
              return GalleryVideoPlayer(
                key: ValueKey(item.id),
                url: item.fileUrl,
                isFullscreen: _isFullscreen,
                onToggleFullscreen: _toggleFullscreen,
              );
            }
            return InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  item.fileUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white38,
                    size: 48,
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
