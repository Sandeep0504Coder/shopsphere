import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PromotionalVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const PromotionalVideoPlayer({super.key, required this.videoUrl});

  @override
  State<PromotionalVideoPlayer> createState() => _PromotionalVideoPlayerState();
}

class _PromotionalVideoPlayerState extends State<PromotionalVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..setLooping(true)            // 🔁 Loop the video
      ..setVolume(0.0)
      ..initialize().then((_) {
        setState(() {}); // Rebuild when video is ready
        _controller.play(); // Auto-play
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
