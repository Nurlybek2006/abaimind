import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_model.dart';
import '../services/test_service.dart';
import 'auth_provider.dart';

final testServiceProvider = Provider((ref) => TestService());

final testsStreamProvider = StreamProvider<List<TestModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(testServiceProvider).getTests();
});

final testCategoriesProvider = FutureProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Future.value([]);
  return ref.watch(testServiceProvider).getCategories();
});

final dailyChallengeProvider = FutureProvider<TestModel?>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Future.value(null);
  return ref.watch(testServiceProvider).getDailyChallenge();
});

final userResultsProvider =
    StreamProvider.family<List<TestResult>, String>((ref, userId) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(testServiceProvider).getUserResults(userId);
});

// Active test state
final activeTestProvider =
    StateNotifierProvider<ActiveTestNotifier, ActiveTestState?>((ref) {
  return ActiveTestNotifier();
});

class ActiveTestState {
  final TestModel test;
  final int currentIndex;
  final List<int?> answers;
  final int score;
  final int remainingSeconds;

  const ActiveTestState({
    required this.test,
    this.currentIndex = 0,
    required this.answers,
    this.score = 0,
    required this.remainingSeconds,
  });

  ActiveTestState copyWith({
    TestModel? test,
    int? currentIndex,
    List<int?>? answers,
    int? score,
    int? remainingSeconds,
  }) {
    return ActiveTestState(
      test: test ?? this.test,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  bool get isLastQuestion => currentIndex >= test.questions.length - 1;
  double get progress => (currentIndex + 1) / test.questions.length;
  QuestionModel get currentQuestion => test.questions[currentIndex];
}

class ActiveTestNotifier extends StateNotifier<ActiveTestState?> {
  ActiveTestNotifier() : super(null);

  void startTest(TestModel test) {
    state = ActiveTestState(
      test: test,
      answers: List.filled(test.questions.length, null),
      remainingSeconds: test.durationMinutes * 60,
    );
  }

  void answerQuestion(int answerIndex) {
    if (state == null) return;
    final answers = List<int?>.from(state!.answers);
    answers[state!.currentIndex] = answerIndex;
    final isCorrect =
        answerIndex == state!.currentQuestion.correctIndex;
    state = state!.copyWith(
      answers: answers,
      score: isCorrect ? state!.score + 1 : state!.score,
    );
  }

  void nextQuestion() {
    if (state == null || state!.isLastQuestion) return;
    state = state!.copyWith(currentIndex: state!.currentIndex + 1);
  }

  void decrementTimer() {
    if (state == null || state!.remainingSeconds <= 0) return;
    state = state!.copyWith(remainingSeconds: state!.remainingSeconds - 1);
  }

  void reset() {
    state = null;
  }

  TestResult? getResult(String userId) {
    if (state == null) return null;
    final test = state!.test;
    final correctAnswers = state!.score;
    final percentage = (correctAnswers / test.questions.length * 100).round();
    final pointsEarned =
        (test.pointsReward * correctAnswers / test.questions.length).round();

    return TestResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testId: test.id,
      userId: userId,
      score: percentage,
      totalQuestions: test.questions.length,
      correctAnswers: correctAnswers,
      pointsEarned: pointsEarned,
      completedAt: DateTime.now(),
      timeTakenSeconds:
          test.durationMinutes * 60 - state!.remainingSeconds,
    );
  }
}
