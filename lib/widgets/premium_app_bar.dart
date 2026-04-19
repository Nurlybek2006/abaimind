import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading ??
          (showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
