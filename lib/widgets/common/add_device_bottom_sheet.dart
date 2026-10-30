import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../utils/form_validators.dart';
import '../../utils/mac_address_formatter.dart';
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
    this.helperText,
    this.qrButtonLabel,
    this.onScanQr,
    this.tipHighlight,
    this.tipText,
    this.tipIcon,
  });

  final String title;
  final String description;
  final String idLabel;
  final IconData icon;
  final String submitLabel;
  final bool isLoading;
  final Future<bool> Function(String id) onSubmit;
  final String? helperText;
  final String? qrButtonLabel;
  final VoidCallback? onScanQr;
  final String? tipHighlight;
  final String? tipText;
  final IconData? tipIcon;

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

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) {
      final formatted = MacAddressInputFormatter().formatEditUpdate(
        _idController.value,
        TextEditingValue(text: text),
      );
      _idController.value = formatted;
    }
  }

  void _showQrUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR code scanner is not available on this device.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _DragHandle(),
                _HeaderRow(
                  title: widget.title,
                  description: widget.description,
                  isLoading: widget.isLoading,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.idLabel,
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.primaryAccent,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _idController,
                  autofocus: true,
                  inputFormatters: [MacAddressInputFormatter()],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 1.2,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'XX:XX:XX:XX:XX:XX',
                    hintStyle: TextStyle(
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                    prefixIcon: Icon(
                      widget.icon,
                      color: AppColors.primaryAccent,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.content_paste_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Paste',
                      onPressed: _handlePaste,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFBFDFB),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: AppRadius.borderXl,
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.borderXl,
                      borderSide: BorderSide(
                        color: AppColors.secondaryAccent.withValues(alpha: 0.7),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.borderXl,
                      borderSide: BorderSide(
                        color: AppColors.primaryAccent,
                        width: 2.0,
                      ),
                    ),
                  ),
                  validator: (value) =>
                      validateMacAddress(value, fieldName: widget.idLabel),
                ),
                if (widget.helperText case final helperText?) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.primaryAccent,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          helperText,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                const _OrDivider(),
                const SizedBox(height: 12),
                _ScanQrButton(
                  label: widget.qrButtonLabel ?? 'Scan device QR code',
                  onPressed: widget.onScanQr ?? () => _showQrUnavailable(context),
                ),
                const SizedBox(height: 12),
                AppLoadingButton(
                  isLoading: widget.isLoading,
                  onPressed: _handleSubmit,
                  label: widget.submitLabel,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderXl,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (widget.tipText case final tipText?) ...[
                  const SizedBox(height: 16),
                  _TipCard(
                    icon: widget.tipIcon ?? Icons.sensors_rounded,
                    highlight: widget.tipHighlight,
                    text: tipText,
                  ),
                ],
              ],
            ),
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
        width: 48,
        height: 6,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFD5DCD6),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.title,
    required this.description,
    required this.isLoading,
  });

  final String title;
  final String description;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF5EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.borderLight, height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.borderLight, height: 1),
        ),
      ],
    );
  }
}

class _ScanQrButton extends StatelessWidget {
  const _ScanQrButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7FAF8),
      borderRadius: AppRadius.borderXl,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.borderXl,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderXl,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.qr_code_scanner_rounded,
                size: 18,
                color: AppColors.primaryAccent,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    this.highlight,
    required this.text,
  });

  final IconData icon;
  final String? highlight;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: AppRadius.borderXl,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primaryAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: highlight != null ? '$highlight ' : null,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: text,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
