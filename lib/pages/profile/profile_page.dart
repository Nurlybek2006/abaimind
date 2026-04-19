import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gold_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_widget.dart';
import '../../models/user_model.dart';
import '../auth/welcome_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = ref.watch(themeProvider);

    return userAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorWidget2(message: e.toString()),
      data: (user) {
        if (user == null) return const LoadingWidget();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.backgroundLight,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 16),
              Text(
                user.fullName,
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 4),
              Text(
                '${user.group} • ${user.course}-курс',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gold,
                    ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
              // Stats
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    label: AppStrings.totalPoints,
                    value: '${user.totalPoints}',
                    icon: Icons.stars_rounded,
                    iconColor: AppColors.gold,
                  ),
                  StatCard(
                    label: AppStrings.completedTests,
                    value: '${user.completedTests}',
                    icon: Icons.assignment_turned_in_outlined,
                    iconColor: AppColors.success,
                  ),
                  StatCard(
                    label: AppStrings.streak,
                    value: '${user.streak} күн',
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppColors.warning,
                  ),
                  StatCard(
                    label: AppStrings.achievements,
                    value: '${user.badges.length}',
                    icon: Icons.emoji_events_outlined,
                    iconColor: AppColors.info,
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 24),
              // Settings
              GoldCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: AppStrings.darkMode,
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) =>
                            ref.read(themeProvider.notifier).toggle(),
                        activeTrackColor: AppColors.gold,
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.edit_outlined,
                      title: AppStrings.editProfile,
                      onTap: () => _showEditProfileSheet(context, ref, user),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      title: AppStrings.logout,
                      titleColor: AppColors.error,
                      iconColor: AppColors.error,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text(AppStrings.logout),
                            content: const Text(AppStrings.areYouSure),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text(AppStrings.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(AppStrings.confirm,
                                    style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(currentUserProvider.notifier).signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const WelcomePage()),
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

void _showEditProfileSheet(
    BuildContext context, WidgetRef ref, UserModel user) {
  final nameCtrl = TextEditingController(text: user.fullName);
  final groupCtrl = TextEditingController(text: user.group);
  final courseCtrl = TextEditingController(text: user.course.toString());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      bool loading = false;
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppStrings.editProfile,
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Аты-жөні',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: groupCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Топ',
                    prefixIcon: Icon(Icons.group_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Курс',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) return;
                            setState(() => loading = true);
                            final updated = user.copyWith(
                              fullName: name,
                              group: groupCtrl.text.trim(),
                              course: int.tryParse(courseCtrl.text.trim()) ??
                                  user.course,
                            );
                            await ref
                                .read(currentUserProvider.notifier)
                                .updateProfile(updated);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text('Сақтау'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? AppColors.gold),
      title: Text(title,
          style: TextStyle(color: titleColor)),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.gold)
              : null),
      onTap: onTap,
    );
  }
}
