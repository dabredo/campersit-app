import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/form_validators.dart';
import '../utils/mac_address_formatter.dart';
import 'app_loading_button.dart';

class AddDeviceBottomSheet extends StatefulWidget {
  const AddDeviceBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.idLabel,
    required this.icon,
    required this.submitLabel,
    required this.isLoading,
    required this.onSubmit,
  });

  final String title;
  final String description;
  final String idLabel;
  final IconData icon;
  final String submitLabel;
  final bool isLoading;
  final Future<bool> Function(String id) onSubmit;

  static Future<void> show(
    BuildContext context, {
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  @override
  State<AddDeviceBottomSheet> createState() => _AddDeviceBottomSheetState();
}

class _AddDeviceBottomSheetState extends State<AddDeviceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final isSuccess = await widget.onSubmit(_idController.text.trim());
    if (isSuccess && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final textTheme = Theme.of(context).textTheme;

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
              const _DragHandle(),
              _HeaderRow(
                title: widget.title,
                isLoading: widget.isLoading,
              ),
              const SizedBox(height: 6),
              Text(
                widget.description,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _idController,
                autofocus: true,
                inputFormatters: [MacAddressInputFormatter()],
                decoration: InputDecoration(
                  labelText: widget.idLabel,
                  hintText: 'xx:xx:xx:xx:xx:xx',
                  prefixIcon: Icon(widget.icon),
                ),
                validator: (value) =>
                    validateMacAddress(value, fieldName: widget.idLabel),
              ),
              const SizedBox(height: 24),
              AppLoadingButton(
                isLoading: widget.isLoading,
                onPressed: _handleSubmit,
                label: widget.submitLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.title, required this.isLoading});

  final String title;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
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
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
