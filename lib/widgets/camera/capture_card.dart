import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/capture.dart';
import '../../providers/capture_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_time_formatter.dart';
import 'capture_video_player.dart';

class CaptureCard extends ConsumerWidget {
  final Capture capture;

  const CaptureCard({super.key, required this.capture});

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final isConfirmed = await showDialog<bool>(
          context: context,
          builder: (_) => DeleteCaptureDialog(captureId: capture.id),
        ) ??
        false;

    if (!isConfirmed || !context.mounted) return;

    await ref
        .read(deleteCaptureControllerProvider(capture.id).notifier)
        .deleteCapture();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = formatDateTime(capture.createdAt);
    final isDeleting = ref.watch(deleteCaptureControllerProvider(capture.id));

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
              DeleteCaptureButton(
                captureId: capture.id,
                isLoading: isDeleting,
                onTap: isDeleting ? () {} : () => _confirmAndDelete(context, ref),
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

class DeleteCaptureButton extends StatelessWidget {
  const DeleteCaptureButton({
    super.key,
    required this.captureId,
    required this.onTap,
    this.isLoading = false,
  });

  final String captureId;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: AppColors.danger,
        ),
      );
    }

    return InkWell(
      key: ValueKey('delete_capture_$captureId'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(
          Icons.delete_outline_rounded,
          size: 18,
          color: AppColors.danger,
        ),
      ),
    );
  }
}

class DeleteCaptureDialog extends StatelessWidget {
  const DeleteCaptureDialog({super.key, required this.captureId});

  final String captureId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border2Xl),
      title: Text(
        'Delete Capture',
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this recording ($captureId)? This action cannot be undone.',
        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderXl,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Delete',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
