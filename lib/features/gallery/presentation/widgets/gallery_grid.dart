import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../models/gallery_item.dart';
import '../gallery_viewer_page.dart';

typedef GalleryPageFetcher = Future<List<GalleryItem>> Function(int skip, int take);

/// Paginated, pull-to-refresh grid of gallery thumbnails, shared by every
/// gallery tab (a student's photos, the shared feed) - each just supplies
/// a different [fetchPage] callback.
class GalleryGrid extends StatefulWidget {
  final GalleryPageFetcher fetchPage;
  final String emptyMessage;

  const GalleryGrid({super.key, required this.fetchPage, required this.emptyMessage});

  @override
  State<GalleryGrid> createState() => _GalleryGridState();
}

class _GalleryGridState extends State<GalleryGrid> {
  static const _pageSize = 30;

  final _items = <GalleryItem>[];
  final _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoading) return;
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 300) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final page = await widget.fetchPage(_items.length, _pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _hasMore = page.length == _pageSize;
      });
      // A short first page might not fill the viewport, so the scroll
      // position never reaches "near the bottom" to trigger the next
      // fetch on its own - keep loading until either it does, or there's
      // nothing left.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        if (_hasMore && !_isLoading && _scrollController.position.maxScrollExtent <= 0) {
          _loadNextPage();
        }
      });
    } catch (_) {
      if (mounted) setState(() => _error = "Couldn't load gallery items");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _hasMore = true;
      _error = null;
    });
    await _loadNextPage();
  }

  void _openViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GalleryViewerPage(items: _items, initialIndex: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty && _error != null) {
      return _MessageState(
        icon: Icons.wifi_off_outlined,
        message: _error!,
        actionLabel: 'Retry',
        onAction: _loadNextPage,
      );
    }

    if (_items.isEmpty) {
      return _MessageState(icon: Icons.photo_outlined, message: widget.emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.m),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AppSpacing.s,
          crossAxisSpacing: AppSpacing.s,
        ),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Center(
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final item = _items[index];
          return _GalleryTile(item: item, onTap: () => _openViewer(index));
        },
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback onTap;

  const _GalleryTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isVideo = item.mediaType == GalleryMediaType.video;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: isVideo
            ? _VideoThumbnail(url: item.fileUrl)
            : Image.network(
                item.fileUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(color: colorScheme.surfaceContainerHighest);
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image_outlined, color: colorScheme.onSurfaceVariant),
                ),
              ),
      ),
    );
  }
}

/// Generates a real frame from the video as the grid thumbnail, instead of
/// a flat placeholder. Cached in memory per URL so scrolling back to an
/// already-seen tile doesn't regenerate it.
class _VideoThumbnailCache {
  _VideoThumbnailCache._();
  static final Map<String, Uint8List> _cache = {};

  static Uint8List? get(String url) => _cache[url];
  static void put(String url, Uint8List data) => _cache[url] = data;
}

class _VideoThumbnail extends StatefulWidget {
  final String url;

  const _VideoThumbnail({required this.url});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = _VideoThumbnailCache.get(widget.url);
    if (cached != null) {
      setState(() => _bytes = cached);
      return;
    }
    try {
      final data = await VideoThumbnail.thumbnailData(
        video: widget.url,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        quality: 60,
      );
      _VideoThumbnailCache.put(widget.url, data);
      if (mounted) setState(() => _bytes = data);
    } catch (_) {
      // Falls back to the plain placeholder below - not fatal.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bytes = _bytes;

    return Stack(
      fit: StackFit.expand,
      children: [
        bytes != null
            ? Image.memory(bytes, fit: BoxFit.cover)
            : Container(color: colorScheme.surfaceContainerHighest),
        Container(
          alignment: Alignment.center,
          color: bytes != null ? Colors.black.withValues(alpha: 0.15) : Colors.transparent,
          child: Icon(Icons.play_circle_fill, color: Colors.white.withValues(alpha: 0.9), size: 32),
        ),
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({required this.icon, required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.m),
          Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.m),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
