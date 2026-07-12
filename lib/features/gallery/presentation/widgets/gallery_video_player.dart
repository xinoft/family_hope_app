import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Inline video playback for the full-screen gallery viewer - tap to
/// toggle play/pause, with a scrub bar pinned to the bottom. Fullscreen
/// (landscape + hidden chrome) is owned by the parent page - this widget
/// only shows the toggle button and reports taps via [onToggleFullscreen].
class GalleryVideoPlayer extends StatefulWidget {
  final String url;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  const GalleryVideoPlayer({
    super.key,
    required this.url,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  @override
  State<GalleryVideoPlayer> createState() => _GalleryVideoPlayerState();
}

class _GalleryVideoPlayerState extends State<GalleryVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isReady = true);
        _controller.play();
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _hasError = true);
      });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Text('Unable to play this video', style: TextStyle(color: Colors.white70)),
      );
    }
    if (!_isReady) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return GestureDetector(
      onTap: _togglePlayback,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          if (!_controller.value.isPlaying)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.45)),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.35),
              child: Row(
                children: [
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.all(12),
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onToggleFullscreen,
                    icon: Icon(
                      widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
