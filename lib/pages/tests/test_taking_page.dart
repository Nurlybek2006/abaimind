import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/test_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/test_provider.dart';
import 'test_result_page.dart';

class TestTakingPage extends ConsumerStatefulWidget {
  final TestModel test;

  const TestTakingPage({super.key, required this.test});

  @override
  ConsumerState<TestTakingPage> createState() => _TestTakingPageState();
}

class _TestTakingPageState extends ConsumerState<TestTakingPage>
    with TickerProviderStateMixin {
  late Timer _timer;
  int? _selectedAnswer;
  bool _answered = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Delay provider modification to avoid "modifying provider during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeTestProvider.notifier).startTest(widget.test);
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = ref.read(activeTestProvider);
      if (state == null) return;
      if (state.remainingSeconds <= 0) {
        _timer.cancel();
        _finishTest();
        return;
      }
      ref.read(activeTestProvider.notifier).decrementTimer();
    });
  }

  void _answerQuestion(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });

    final state = ref.read(activeTestProvider);
    if (state == null) return;

    final isCorrect = index == state.currentQuestion.correctIndex;
    ref.read(activeTestProvider.notifier).answerQuestion(index);

    if (!isCorrect) {
      _shakeController.forward().then((_) => _shakeController.reset());
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final current = ref.read(activeTestProvider);
      if (current == null) return;

      if (current.isLastQuestion) {
        _finishTest();
      } else {
        ref.read(activeTestProvider.notifier).nextQuestion();
        setState(() {
          _selectedAnswer = null;
          _answered = false;
        });
      }
    });
  }

  void _finishTest() {
    _timer.cancel();
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final result =
        ref.read(activeTestProvider.notifier).getResult(user.uid);
    if (result == null) return;

    ref.read(testServiceProvider).submitResult(result);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TestResultPage(result: result, test: widget.test),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _shakeController.dispose();
    // Delay provider reset to avoid modification during dispose lifecycle
    Future.microtask(() {
      ref.read(activeTestProvider.notifier).reset();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeTestProvider);
    if (state == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final question = state.currentQuestion;
    final minutes = state.remainingSeconds ~/ 60;
    final seconds = state.remainingSeconds % 60;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.gold),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Тестті аяқтау'),
                          content: const Text(AppStrings.areYouSure),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(AppStrings.cancel),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _finishTest();
                              },
                              child: const Text(AppStrings.finishTest,
                                  style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: LinearPercentIndicator(
                      lineHeight: 10,
                      percent: state.progress,
                      backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                      linearGradient: AppColors.goldGradient,
                      barRadius: const Radius.circular(8),
                      animation: true,
                      animateFromLastPercent: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.remainingSeconds < 60
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: state.remainingSeconds < 60
                              ? AppColors.error
                              : AppColors.gold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: state.remainingSeconds < 60
                                ? AppColors.error
                                : AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Question counter
              Text(
                '${state.currentIndex + 1} / ${state.test.questions.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              // Question
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (question.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            question.imageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        question.text,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  height: 1.4,
                                ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 32),
                      // Options
                      ...List.generate(question.options.length, (i) {
                        final isSelected = _selectedAnswer == i;
                        final isCorrect = i == question.correctIndex;
                        Color? bgColor;
                        Color? borderColor;

                        if (_answered) {
                          if (isCorrect) {
                            bgColor = AppColors.success.withValues(alpha: 0.1);
                            borderColor = AppColors.success;
                          } else if (isSelected && !isCorrect) {
                            bgColor = AppColors.error.withValues(alpha: 0.1);
                            borderColor = AppColors.error;
                          }
                        } else if (isSelected) {
                          bgColor = AppColors.gold.withValues(alpha: 0.1);
                          borderColor = AppColors.gold;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: InkWell(
                              onTap: () => _answerQuestion(i),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: borderColor ??
                                        AppColors.gold
                                            .withValues(alpha: 0.2),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: borderColor
                                                ?.withValues(alpha: 0.15) ??
                                            AppColors.gold
                                                .withValues(alpha: 0.1),
                                      ),
                                      child: Center(
                                        child: _answered && isCorrect
                                            ? const Icon(Icons.check,
                                                color: AppColors.success,
                                                size: 20)
                                            : _answered &&
                                                    isSelected &&
                                                    !isCorrect
                                                ? const Icon(Icons.close,
                                                    color: AppColors.error,
                                                    size: 20)
                                                : Text(
                                                    String.fromCharCode(
                                                        65 + i),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: borderColor ??
                                                          AppColors.gold,
                                                    ),
                                                  ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        question.options[i],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: (i * 100).ms)
                            .slideX(begin: 0.1);
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
