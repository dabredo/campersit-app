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
import '../widgets/common/custom_scaffold.dart';
import '../widgets/common/section_header.dart';

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
    final capturesAsync = ref.watch(
      cameraCapturesProvider((gatewayId: gatewayId, sensorId: sensor.id)),
    );
    final captures = capturesAsync.value;
    final title =
        captures != null ? 'RECORDINGS (${captures.length})' : 'RECORDINGS';

    return CustomScaffold(
      title: title,
      showBackButton: true,
      body: switch (capturesAsync) {
        AsyncLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          ),
        AsyncError(:final error) => AppErrorState(
            title: 'Error loading recordings',
            message: AppErrorFormatter.format(error),
          ),
        AsyncData(:final value) =>
          _CameraCapturesList(captures: value, sensor: sensor),
      },
    );
  }
}

class _CameraCapturesList extends StatelessWidget {
  final List<Capture> captures;
  final Sensor sensor;

  const _CameraCapturesList({
    required this.captures,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          title: 'Recordings for ${sensor.displayName}',
          subtitle:
              'Motion-triggered video recordings captured by this camera.',
        ),
        const SizedBox(height: 16),
        if (captures.isEmpty)
          const AppEmptyState(
            icon: Icons.videocam_off_rounded,
            title: 'No Recordings Found',
            message:
                'Recorded videos will be listed here when captures are available.',
          )
        else
          for (var i = 0; i < captures.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            CaptureCard(capture: captures[i]),
          ],
      ],
    );
  }
}
