import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/capture.dart';
import '../models/sensor.dart';
import '../providers/capture_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../widgets/camera/capture_card.dart';
import '../widgets/common/app_empty_state.dart';

class CameraCapturesScreen extends ConsumerWidget {
  final String gatewayId;
  final Sensor sensor;

  const CameraCapturesScreen({
    super.key,
    required this.gatewayId,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = (sensor.tag != null && sensor.tag!.trim().isNotEmpty)
        ? sensor.tag!.trim()
        : sensor.id;

    final capturesAsync = ref.watch(
      cameraCapturesProvider((gatewayId: gatewayId, sensorId: sensor.id)),
    );

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text('$title Recordings'),
      ),
      body: switch (capturesAsync) {
        AsyncLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          ),
        AsyncError(:final error) => _CameraCapturesError(
            message: AppErrorFormatter.format(error),
          ),
        AsyncData(:final value) when value.isEmpty => const AppEmptyState(
            icon: Icons.videocam_off_rounded,
            title: 'No Recordings Found',
            message:
                'Recorded videos will be listed here when captures are available.',
          ),
        AsyncData(:final value) => _CameraCapturesList(captures: value),
      },
    );
  }
}

class _CameraCapturesError extends StatelessWidget {
  final String message;

  const _CameraCapturesError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              'Error loading recordings',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraCapturesList extends StatelessWidget {
  final List<Capture> captures;

  const _CameraCapturesList({required this.captures});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: captures.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return CaptureCard(capture: captures[index]);
      },
    );
  }
}
