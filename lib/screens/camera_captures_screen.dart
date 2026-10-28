import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/capture.dart';
import '../models/sensor.dart';
import '../providers/capture_providers.dart';
import '../theme/app_theme.dart';
import '../utils/error_formatter.dart';
import '../widgets/camera/capture_card.dart';
import '../widgets/common/app_empty_state.dart';
import '../widgets/common/app_error_state.dart';

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
    final title = sensor.displayName;

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
        AsyncError(:final error) => AppErrorState(
            title: 'Error loading recordings',
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
