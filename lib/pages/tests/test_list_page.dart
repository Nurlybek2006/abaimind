import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/test_model.dart';
import '../../providers/test_provider.dart';
import '../../widgets/gold_card.dart';
import '../../widgets/loading_widget.dart';
import 'test_taking_page.dart';

class TestListPage extends ConsumerWidget {
  const TestListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(testsStreamProvider);
    final dailyAsync = ref.watch(dailyChallengeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Challenge
          dailyAsync.when(
            loading: () => const SizedBox(),
            error: (e, st) => const SizedBox(),
            data: (daily) {
              if (daily == null) return const SizedBox();
              return _DailyChallengeCard(test: daily)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.2);
            },
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.tests,
            style: Theme.of(context).textTheme.headlineLarge,
          ).animate().fadeIn(),
          const SizedBox(height: 16),
          testsAsync.when(
            loading: () => const LoadingWidget(),
            error: (e, _) => ErrorWidget2(message: e.toString()),
            data: (tests) {
              if (tests.isEmpty) {
                return const EmptyWidget(
                  message: 'Тесттер жоқ',
                  icon: Icons.quiz_outlined,
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  return _TestCard(test: tests[index])
                      .animate()
                      .fadeIn(delay: (index * 80).ms)
                      .slideX(begin: 0.1);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final TestModel test;

  const _DailyChallengeCard({required this.test});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: AppColors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                AppStrings.dailyChallenge,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            test.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${test.questions.length} ${AppStrings.questions} • ${test.durationMinutes} ${AppStrings.minutes} • ${test.pointsReward} ${AppStrings.points}',
            style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TestTakingPage(test: test),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.goldDark,
                elevation: 0,
              ),
              child: const Text(AppStrings.startTest),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final TestModel test;

  const _TestCard({required this.test});

  @override
  Widget build(BuildContext context) {
    return GoldCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TestTakingPage(test: test),
          ),
        );
      },
      hasBorder: true,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: _getDifficultyGradient(test.difficulty),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.quiz_rounded,
                color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.help_outline,
                      text: '${test.questions.length}',
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      text: '${test.durationMinutes} мин',
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.stars_rounded,
                      text: '${test.pointsReward}',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(test.difficulty)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getDifficultyLabel(test.difficulty),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getDifficultyColor(test.difficulty),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gold),
        ],
      ),
    );
  }

  LinearGradient _getDifficultyGradient(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF43A047)]);
      case Difficulty.medium:
        return const LinearGradient(
            colors: [Color(0xFFFFB74D), Color(0xFFF57C00)]);
      case Difficulty.hard:
        return const LinearGradient(
            colors: [Color(0xFFEF5350), Color(0xFFC62828)]);
    }
  }

  Color _getDifficultyColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return AppColors.success;
      case Difficulty.medium:
        return AppColors.warning;
      case Difficulty.hard:
        return AppColors.error;
    }
  }

  String _getDifficultyLabel(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return AppStrings.easy;
      case Difficulty.medium:
        return AppStrings.medium;
      case Difficulty.hard:
        return AppStrings.hard;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
      ],
    );
  }
}
