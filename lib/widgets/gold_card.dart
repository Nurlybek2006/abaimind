import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GoldCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool hasBorder;
  final double? elevation;

  const GoldCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.hasBorder = false,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: hasBorder
            ? Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black26
                : AppColors.gold.withValues(alpha: 0.1),
            blurRadius: elevation ?? 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
