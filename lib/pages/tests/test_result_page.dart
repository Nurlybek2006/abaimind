import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/test_model.dart';
import '../../widgets/gold_button.dart';

class TestResultPage extends StatelessWidget {
  final TestResult result;
  final TestModel test;

  const TestResultPage({
    super.key,
    required this.result,
    required this.test,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = result.score;
    final isGreat = percentage >= 80;
    final isGood = percentage >= 50;
    final random = Random();
    final motivationIndex =
        random.nextInt(AppStrings.motivationalMessages.length);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Trophy icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: isGreat
                      ? AppColors.premiumGradient
                      : isGood
                          ? const LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF43A047)])
                          : const LinearGradient(
                              colors: [Color(0xFFEF5350), Color(0xFFC62828)]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isGreat
                              ? AppColors.gold
                              : isGood
                                  ? AppColors.success
                                  : AppColors.error)
                          .withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  isGreat
                      ? Icons.emoji_events_rounded
                      : isGood
                          ? Icons.thumb_up_rounded
                          : Icons.sentiment_neutral_rounded,
                  size: 48,
                  color: AppColors.white,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.3, 0.3)),
              const SizedBox(height: 24),
              Text(
                AppStrings.testCompleted,
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 8),
              Text(
                test.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),
              // Score circle
              CircularPercentIndicator(
                radius: 80,
                lineWidth: 12,
                percent: percentage / 100,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      AppStrings.yourScore,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                progressColor: isGreat
                    ? AppColors.gold
                    : isGood
                        ? AppColors.success
                        : AppColors.error,
                backgroundColor: AppColors.gold.withValues(alpha: 0.1),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1500,
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 32),
              // Stats row
              Row(
                children: [
                  _ResultStat(
                    icon: Icons.check_circle_outline,
                    label: AppStrings.correctAnswers,
                    value: '${result.correctAnswers}',
                    color: AppColors.success,
                  ),
                  _ResultStat(
                    icon: Icons.cancel_outlined,
                    label: AppStrings.wrongAnswers,
                    value:
                        '${result.totalQuestions - result.correctAnswers}',
                    color: AppColors.error,
                  ),
                  _ResultStat(
                    icon: Icons.stars_rounded,
                    label: AppStrings.points,
                    value: '+${result.pointsEarned}',
                    color: AppColors.gold,
                  ),
                ],
              ).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 32),
              // Motivational message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.08),
                      AppColors.gold.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  AppStrings.motivationalMessages[motivationIndex],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 900.ms),
              const SizedBox(height: 40),
              GoldButton(
                text: 'Тесттерге оралу',
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ).animate().fadeIn(delay: 1000.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
