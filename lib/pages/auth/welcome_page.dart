import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/gold_button.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.white, AppColors.backgroundLight],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 64,
                    color: AppColors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.5, 0.5)),
                const SizedBox(height: 32),
                // Title
                Text(
                  AppStrings.appName,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(
                        color: AppColors.goldDark,
                        letterSpacing: 2,
                      ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(
                      begin: 0.3,
                      end: 0,
                    ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.appSlogan,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                const Spacer(flex: 2),
                // Decorative line
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ).animate().fadeIn(delay: 500.ms).scaleX(begin: 0),
                const SizedBox(height: 40),
                // Buttons
                GoldButton(
                  text: AppStrings.login,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPage()),
                    );
                  },
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                const SizedBox(height: 16),
                GoldButton(
                  text: AppStrings.register,
                  isOutlined: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterPage()),
                    );
                  },
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
