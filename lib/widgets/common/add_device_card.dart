import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AddDeviceCard extends StatelessWidget {
  const AddDeviceCard({
    super.key,
    required this.title,
    this.icon = Icons.add_rounded,
    this.margin,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final EdgeInsetsGeometry? margin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.border2Xl,
        child: CustomPaint(
          foregroundPainter: _DashedBorderPainter(
            color: AppColors.primaryAccent.withValues(alpha: 0.45),
            strokeWidth: 1.5,
            radius: const Radius.circular(AppRadius.rounded2Xl),
          ),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: const BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: AppRadius.border2Xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryAccent.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final resolvedMargin = margin;
    if (resolvedMargin != null) {
      return Padding(padding: resolvedMargin, child: card);
    }
    return card;
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  static const double _dashWidth = 6.0;
  static const double _dashSpace = 4.0;

  final Color color;
  final double strokeWidth;
  final Radius radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= strokeWidth || size.height <= strokeWidth) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      radius,
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + _dashWidth < metric.length)
            ? _dashWidth
            : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += _dashWidth + _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      radius != oldDelegate.radius;
}
