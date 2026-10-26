import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../theme/app_theme.dart';

class CaptureVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const CaptureVideoPlayer({super.key, required this.videoUrl});

  @override
  State<CaptureVideoPlayer> createState() => _CaptureVideoPlayerState();
}

class _CaptureVideoPlayerState extends State<CaptureVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startPlayback() async {
    if (_controller != null) {
      if (_controller!.value.isPlaying) {
        await _controller!.pause();
      } else {
        await _controller!.play();
      }
      if (mounted) setState(() {});
      return;
    }

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await controller.initialize();
      controller.addListener(_onControllerUpdate);
      await controller.play();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitializing = false;
        });
      } else {
        await controller.dispose();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Failed to load video';
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return ClipRRect(
      borderRadius: AppRadius.borderXl,
      child: Container(
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: controller?.value.isInitialized == true &&
                  controller != null &&
                  controller.value.aspectRatio > 0
              ? controller.value.aspectRatio
              : 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (controller != null && controller.value.isInitialized)
                VideoPlayer(controller)
              else
                Container(
                  color: AppColors.textPrimary,
                  child: const Center(
                    child: Icon(
                      Icons.videocam_rounded,
                      size: 48,
                      color: AppColors.borderLight,
                    ),
                  ),
                ),
              if (_isInitializing)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAccent,
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.danger,
                          size: 32,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _errorMessage ?? '',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _startPlayback,
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: AppColors.secondaryAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _VideoOverlayControls(
                  isPlaying: controller?.value.isPlaying ?? false,
                  hasEnded: controller != null &&
                      controller.value.isInitialized &&
                      controller.value.position >= controller.value.duration,
                  onTogglePlay: _startPlayback,
                ),
              if (controller != null && controller.value.isInitialized)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _VideoProgressIndicatorBar(controller: controller),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoOverlayControls extends StatelessWidget {
  final bool isPlaying;
  final bool hasEnded;
  final VoidCallback onTogglePlay;

  const _VideoOverlayControls({
    required this.isPlaying,
    required this.hasEnded,
    required this.onTogglePlay,
  });

  @override
  Widget build(BuildContext context) {
    if (isPlaying) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTogglePlay,
        child: const SizedBox.expand(),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTogglePlay,
      child: Container(
        color: Colors.black38,
        child: Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasEnded ? Icons.replay_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoProgressIndicatorBar extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoProgressIndicatorBar({required this.controller});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final position = controller.value.position;
    final duration = controller.value.duration;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black87],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.primaryAccent,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white10,
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${_formatDuration(position)} / ${_formatDuration(duration)}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
