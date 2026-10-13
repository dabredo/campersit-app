import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/gateway_providers.dart';
import '../theme/app_theme.dart';
import '../utils/form_validators.dart';
import 'app_loading_button.dart';

class AddGatewayBottomSheet extends ConsumerStatefulWidget {
  const AddGatewayBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddGatewayBottomSheet(),
    );
  }

  @override
  ConsumerState<AddGatewayBottomSheet> createState() =>
      _AddGatewayBottomSheetState();
}

class _AddGatewayBottomSheetState extends ConsumerState<AddGatewayBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final isSuccess = await ref
        .read(addGatewayControllerProvider.notifier)
        .addGateway(_idController.text.trim());

    if (isSuccess && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isLoading = ref.watch(addGatewayControllerProvider).isLoading;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.rounded2Xl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Gateway',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter the Gateway ID of your device to link it to your account.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _idController,
                autofocus: true,
                inputFormatters: [_MacAddressInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Gateway ID',
                  hintText: 'xx:xx:xx:xx:xx:xx',
                  prefixIcon: Icon(Icons.router_outlined),
                ),
                validator: validateMacAddress,
              ),
              const SizedBox(height: 24),
              AppLoadingButton(
                isLoading: isLoading,
                onPressed: _handleSubmit,
                label: 'Add Gateway',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var rawHexCharacters = newValue.text
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '')
        .toUpperCase();
    final previousRawHexCharacters = oldValue.text
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '')
        .toUpperCase();

    if (newValue.text.length < oldValue.text.length &&
        rawHexCharacters == previousRawHexCharacters &&
        rawHexCharacters.isNotEmpty) {
      rawHexCharacters = rawHexCharacters.substring(
        0,
        rawHexCharacters.length - 1,
      );
    }

    if (rawHexCharacters.length > 12) {
      rawHexCharacters = rawHexCharacters.substring(0, 12);
    }

    final formattedTextBuffer = StringBuffer();
    for (var index = 0; index < rawHexCharacters.length; index++) {
      if (index > 0 && index % 2 == 0) {
        formattedTextBuffer.write(':');
      }
      formattedTextBuffer.write(rawHexCharacters[index]);
    }

    final formattedText = formattedTextBuffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
