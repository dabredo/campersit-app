import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/gateway_providers.dart';
import 'add_device_bottom_sheet.dart';

class AddSensorBottomSheet extends ConsumerWidget {
  const AddSensorBottomSheet({super.key, required this.gatewayId});

  final String gatewayId;

  static Future<void> show(BuildContext context, {required String gatewayId}) {
    return AddDeviceBottomSheet.show(
      context,
      builder: (context) => AddSensorBottomSheet(gatewayId: gatewayId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref
        .watch(addSensorControllerProvider(gatewayId))
        .isLoading;

    return AddDeviceBottomSheet(
      title: 'Add Sensor',
      description:
          'Enter the Sensor ID of your device to link it to this gateway.',
      idLabel: 'Sensor ID',
      icon: Icons.sensors_rounded,
      submitLabel: 'Add Sensor',
      isLoading: isLoading,
      onSubmit: (id) => ref
          .read(addSensorControllerProvider(gatewayId).notifier)
          .addSensor(id),
    );
  }
}
