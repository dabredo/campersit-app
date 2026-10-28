import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class EditSensorTagButton extends StatelessWidget {
  const EditSensorTagButton({
    super.key,
    required this.sensorId,
    required this.onTap,
  });

  final String sensorId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('edit_sensor_tag_$sensorId'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: const Padding(
        padding: EdgeInsets.all(2),
        child: Icon(
          Icons.edit_outlined,
          size: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class DeleteSensorButton extends StatelessWidget {
  const DeleteSensorButton({
    super.key,
    required this.sensorId,
    required this.onTap,
    this.isLoading = false,
  });

  final String sensorId;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: AppColors.danger,
        ),
      );
    }

    return InkWell(
      key: ValueKey('delete_sensor_$sensorId'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: const Padding(
        padding: EdgeInsets.all(2),
        child: Icon(
          Icons.delete_outline_rounded,
          size: 14,
          color: AppColors.danger,
        ),
      ),
    );
  }
}


class EditSensorTagDialog extends StatefulWidget {
  const EditSensorTagDialog({
    super.key,
    required this.initialTag,
    required this.sensorId,
    required this.onSave,
  });

  final String? initialTag;
  final String sensorId;
  final Future<bool> Function(String newTag) onSave;

  @override
  State<EditSensorTagDialog> createState() => _EditSensorTagDialogState();
}

class _EditSensorTagDialogState extends State<EditSensorTagDialog> {
  late final TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTag ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    final success = await widget.onSave(_controller.text.trim());
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.border2Xl),
      title: Text(
        'Edit Sensor Tag',
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sensor ID: ${widget.sensorId}',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Tag',
              hintText: 'e.g. Living Room, Cabin',
              prefixIcon: Icon(Icons.label_outline_rounded),
            ),
            onFieldSubmitted: _isLoading ? null : (_) => _handleSave(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderXl,
            ),
          ),
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.cardSurface,
                    ),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
