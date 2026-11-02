import 'package:flutter/material.dart';

import '../../models/gateway.dart';
import '../common/add_device_card.dart';
import '../common/app_empty_state.dart';
import '../sensor/add_sensor_bottom_sheet.dart';
import '../sensor/sensor_card.dart';

class SensorsSliver extends StatelessWidget {
  const SensorsSliver({
    super.key,
    required this.gatewayId,
    required this.sensors,
  });

  static const double _wideLayoutBreakpoint = 500;
  static const double _sensorSpacing = 12;

  final String gatewayId;
  final List<Sensor> sensors;

  Widget _buildItem(int index) {
    if (index < sensors.length) {
      return SensorCard(sensor: sensors[index], gatewayId: gatewayId);
    }
    return AddSensorCard(gatewayId: gatewayId);
  }

  @override
  Widget build(BuildContext context) {
    if (sensors.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            const AppEmptyState(
              icon: Icons.sensors_off_rounded,
              title: 'No Sensors Configured',
              message: 'There are no telemetry sensors associated with this gateway yet.',
            ),
            const SizedBox(height: 12),
            AddSensorCard(gatewayId: gatewayId),
          ],
        ),
      );
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen =
            constraints.crossAxisExtent >= _wideLayoutBreakpoint;
        final totalItemCount = sensors.length + 1;

        if (isWideScreen) {
          final rowCount = (totalItemCount + 1) ~/ 2;
          return SliverList.separated(
            itemCount: rowCount,
            separatorBuilder: (_, _) => const SizedBox(height: _sensorSpacing),
            itemBuilder: (_, rowIndex) {
              final firstIndex = rowIndex * 2;
              final secondIndex = firstIndex + 1;
              return _SensorGridRow(
                firstWidget: _buildItem(firstIndex),
                secondWidget: secondIndex < totalItemCount
                    ? _buildItem(secondIndex)
                    : null,
                spacing: _sensorSpacing,
              );
            },
          );
        }

        return SliverList.separated(
          itemCount: totalItemCount,
          separatorBuilder: (_, _) => const SizedBox(height: _sensorSpacing),
          itemBuilder: (_, index) => _buildItem(index),
        );
      },
    );
  }
}

class _SensorGridRow extends StatelessWidget {
  const _SensorGridRow({
    required this.firstWidget,
    required this.secondWidget,
    required this.spacing,
  });

  final Widget firstWidget;
  final Widget? secondWidget;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: firstWidget),
        SizedBox(width: spacing),
        Expanded(child: secondWidget ?? const SizedBox.shrink()),
      ],
    );
  }
}

class AddSensorCard extends StatelessWidget {
  const AddSensorCard({super.key, required this.gatewayId});

  final String gatewayId;

  @override
  Widget build(BuildContext context) {
    return AddDeviceCard(
      title: 'Add Sensor',
      onTap: () => AddSensorBottomSheet.show(context, gatewayId: gatewayId),
    );
  }
}
