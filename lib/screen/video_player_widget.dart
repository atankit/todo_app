import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({Key? key, required this.videoPath}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isMuted = true; // Track mute state
  bool _isPlaying = false; // Track playback state

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {}); // Refresh after initialization
      });
    _controller.setVolume(0.0); // Start muted
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.5) {
      // Video is more than 50% visible, start playback
      if (!_controller.value.isPlaying) {
        _controller.play();
        setState(() {
          _isPlaying = true;
        });
      }
    } else {
      // Less than 50% visible, pause playback
      if (_controller.value.isPlaying) {
        _controller.pause();
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoPath),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video Player
          GestureDetector(
            onTap: _togglePlayPause, // Tap to pause/play
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : Center(child: CircularProgressIndicator()), // Show loader while initializing
          ),
          // Play/Pause Icon
          if (!_isPlaying)
            Center(
              child: Icon(
                Icons.play_arrow,
                size: 64,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          // Mute Button
          Positioned(
            bottom: 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleMute,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
