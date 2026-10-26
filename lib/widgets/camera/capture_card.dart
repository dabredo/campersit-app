import 'package:flutter/material.dart';

import '../../models/capture.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import 'capture_video_player.dart';

class CaptureCard extends StatelessWidget {
  final Capture capture;

  const CaptureCard({super.key, required this.capture});

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDateTime(capture.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderXl,
                ),
                child: const Icon(
                  Icons.videocam_rounded,
                  color: AppColors.primaryAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'ID: ${capture.id}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CaptureVideoPlayer(videoUrl: capture.url),
        ],
      ),
    );
  }
}
