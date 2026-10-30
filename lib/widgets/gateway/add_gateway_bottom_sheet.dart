import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/gateway_providers.dart';
import '../common/add_device_bottom_sheet.dart';


class AddGatewayBottomSheet extends ConsumerWidget {
  const AddGatewayBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AddDeviceBottomSheet.show(
      context,
      builder: (context) => const AddGatewayBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(addGatewayControllerProvider).isLoading;

    return AddDeviceBottomSheet(
      title: 'Add Gateway',
      description:
          'Enter the Gateway ID of your device to link it to your account.',
      idLabel: 'Gateway ID',
      helperText: 'Find the MAC code on the sticker underneath the Hub.',
      tipHighlight: 'Device flashing blue?',
      tipText: 'Press and hold the Reset button for 5 seconds.',
      icon: Icons.router_rounded,
      submitLabel: 'Add Gateway',
      isLoading: isLoading,
      onSubmit: (id) =>
          ref.read(addGatewayControllerProvider.notifier).addGateway(id),
    );
  }
}
