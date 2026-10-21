import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gateway.dart';
import '../providers/gateway_providers.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_formatter.dart';
import '../widgets/app_loading_button.dart';
import '../widgets/add_sensor_bottom_sheet.dart';
import '../widgets/gateway_state_chip.dart';
import '../widgets/sensor_card.dart';

String _formatCoordinates(GatewayLocationPoint point) =>
    '${point.latitude}, ${point.longitude}';

class GatewayDetailScreen extends ConsumerWidget {
  final String gatewayId;
  final Gateway? initialGateway;

  const GatewayDetailScreen({
    super.key,
    required this.gatewayId,
    this.initialGateway,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gatewayAsync = ref.watch(singleGatewayProvider(gatewayId));
    final fallbackGateway = initialGateway;

    return gatewayAsync.when(
      data: (gateway) {
        final currentGateway = gateway ?? fallbackGateway;
        if (currentGateway == null) {
          return const _GatewayMessageScaffold(
            title: 'Gateway Details',
            body: _CenteredMessage('Gateway not found.'),
          );
        }
        return _GatewayDetailContent(gateway: currentGateway);
      },
      loading: () {
        if (fallbackGateway != null) {
          return _GatewayDetailContent(gateway: fallbackGateway);
        }
        return _GatewayMessageScaffold(
          title: gatewayId,
          body: const CircularProgressIndicator(color: AppColors.primaryAccent),
        );
      },
      error: (error, _) {
        if (fallbackGateway != null) {
          return _GatewayDetailContent(gateway: fallbackGateway);
        }
        return _GatewayMessageScaffold(
          title: gatewayId,
          body: _CenteredMessage(
            'Error loading gateway details:\n$error',
            color: AppColors.danger,
          ),
        );
      },
    );
  }
}

class _GatewayMessageScaffold extends StatelessWidget {
  const _GatewayMessageScaffold({required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(title: Text(title)),
      body: Center(child: body),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage(this.message, {this.color = AppColors.textSecondary});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
      ),
    );
  }
}

class _GatewayDetailContent extends StatelessWidget {
  const _GatewayDetailContent({required this.gateway});

  final Gateway gateway;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: Text(gateway.id),
        actions: [
          _DeleteGatewayAction(gatewayId: gateway.id),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GatewayOverviewCard(gateway: gateway),
            const SizedBox(height: 20),
            _SensorsSectionHeader(sensorCount: gateway.sensors.length),
            const SizedBox(height: 12),
            _SensorsList(gatewayId: gateway.id, sensors: gateway.sensors),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.white,
        tooltip: 'Add Sensor',
        onPressed: () =>
            AddSensorBottomSheet.show(context, gatewayId: gateway.id),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DeleteGatewayAction extends ConsumerWidget {
  const _DeleteGatewayAction({required this.gatewayId});

  final String gatewayId;

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final isConfirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) => const _DeleteGatewayDialog(),
        ) ??
        false;
    if (!isConfirmed || !context.mounted) return;

    final isDeleted = await ref
        .read(deleteGatewayControllerProvider(gatewayId).notifier)
        .deleteGateway();
    if (isDeleted && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeleting = ref
        .watch(deleteGatewayControllerProvider(gatewayId))
        .isLoading;

    if (isDeleting) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.danger,
            ),
          ),
        ),
      );
    }

    return IconButton(
      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
      tooltip: 'Delete gateway',
      onPressed: () => _confirmAndDelete(context, ref),
    );
  }
}

class _DeleteGatewayDialog extends StatelessWidget {
  const _DeleteGatewayDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border2Xl),
      title: const Text(
        'Delete Gateway',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: const Text(
        'Are you sure you want to delete this gateway?',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadius.border2Xl,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }
}

class _GatewayOverviewCard extends StatelessWidget {
  const _GatewayOverviewCard({required this.gateway});

  final Gateway gateway;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gateway Information',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'State',
            trailing: GatewayStateChip(state: gateway.state),
          ),
          if (gateway.seenAt case final seenAt?) ...[
            const SizedBox(height: 6),
            _InfoRow(label: 'Last seen', value: formatDateTime(seenAt)),
          ],
          if (gateway.alerts.isNotEmpty) ...[
            const SizedBox(height: 12),
            _AlarmsList(alerts: gateway.alerts),
          ],
          if (gateway.location case final location?) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 12),
            _LocationDetails(location: location),
          ],
          const SizedBox(height: 16),
          _LocalizationButton(gateway: gateway),
        ],
      ),
    );
  }
}

class _AlarmsList extends StatelessWidget {
  const _AlarmsList({required this.alerts});

  final Map<String, Object?> alerts;

  @override
  Widget build(BuildContext context) {
    final alarmStyle = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: AppColors.danger);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alarms:',
          style: alarmStyle?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        for (final MapEntry(:key, :value) in alerts.entries)
          Text('- $key: $value', style: alarmStyle),
      ],
    );
  }
}

class _LocationDetails extends StatelessWidget {
  const _LocationDetails({required this.location});

  final GatewayLocation location;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Details',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        if (location.exact case final exactPoint?)
          _InfoRow(label: 'Exact', value: _formatCoordinates(exactPoint))
        else if (location.approx case final approxPoint?)
          _InfoRow(label: 'Approx', value: _formatCoordinates(approxPoint)),
        if (location.startedAt case final startedAt?) ...[
          const SizedBox(height: 4),
          _InfoRow(label: 'Locating since', value: formatDateTime(startedAt)),
        ],
      ],
    );
  }
}

class _LocalizationButton extends ConsumerWidget {
  const _LocalizationButton({required this.gateway});

  final Gateway gateway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocalizing = gateway.isLocalizing;
    final isToggling = ref
        .watch(toggleLocalizationControllerProvider(gateway.id))
        .isLoading;

    return SizedBox(
      width: double.infinity,
      child: AppLoadingButton(
        isLoading: isToggling,
        onPressed: () => ref
            .read(toggleLocalizationControllerProvider(gateway.id).notifier)
            .toggleLocalization(isCurrentlyLocalizing: isLocalizing),
        label: isLocalizing ? 'Stop Localizing' : 'Request Location',
        icon: Icon(isLocalizing ? Icons.stop_circle : Icons.location_on),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLocalizing
              ? AppColors.warning
              : AppColors.primaryAccent,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, this.value, this.trailing})
    : assert(
        value != null || trailing != null,
        'Either value or trailing must be provided',
      );

  static const double _labelColumnWidth = 95;

  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.bodyMedium;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _labelColumnWidth,
          child: Text(
            label,
            style: baseStyle?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        trailing ??
            Expanded(
              child: Text(
                value!,
                style: baseStyle?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
      ],
    );
  }
}

class _SensorsSectionHeader extends StatelessWidget {
  const _SensorsSectionHeader({required this.sensorCount});

  final int sensorCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final countLabel =
        '$sensorCount ${sensorCount == 1 ? 'sensor' : 'sensors'}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.sensors_rounded,
              color: AppColors.primaryAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Sensors',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withValues(alpha: 0.1),
            borderRadius: AppRadius.borderXl,
          ),
          child: Text(
            countLabel,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryAccent,
            ),
          ),
        ),
      ],
    );
  }
}

class _SensorsList extends StatelessWidget {
  const _SensorsList({required this.gatewayId, required this.sensors});

  static const double _wideLayoutBreakpoint = 500;
  static const double _sensorTileHeight = 96;
  static const double _sensorSpacing = 12;

  final String gatewayId;
  final List<Sensor> sensors;

  @override
  Widget build(BuildContext context) {
    if (sensors.isEmpty) return const _EmptySensorsPlaceholder();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= _wideLayoutBreakpoint;

        if (isWideScreen) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sensors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: _sensorSpacing,
              mainAxisSpacing: _sensorSpacing,
              mainAxisExtent: _sensorTileHeight,
            ),
            itemBuilder: (_, index) =>
                SensorCard(sensor: sensors[index], gatewayId: gatewayId),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sensors.length,
          separatorBuilder: (_, _) => const SizedBox(height: _sensorSpacing),
          itemBuilder: (_, index) =>
              SensorCard(sensor: sensors[index], gatewayId: gatewayId),
        );
      },
    );
  }
}

class _EmptySensorsPlaceholder extends StatelessWidget {
  const _EmptySensorsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _SurfaceCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(
            Icons.sensors_off_rounded,
            size: 44,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'No Sensors Configured',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'There are no telemetry sensors associated with this gateway yet.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
