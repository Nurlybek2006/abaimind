import 'package:cloud_firestore/cloud_firestore.dart';

enum Difficulty { easy, medium, hard }

class TestModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final Difficulty difficulty;
  final int durationMinutes;
  final int pointsReward;
  final List<QuestionModel> questions;
  final String createdBy;
  final DateTime createdAt;
  final bool isDaily;
  final String? imageUrl;

  const TestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.durationMinutes,
    required this.pointsReward,
    required this.questions,
    required this.createdBy,
    required this.createdAt,
    this.isDaily = false,
    this.imageUrl,
  });

  factory TestModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return TestModel(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      difficulty: Difficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => Difficulty.medium,
      ),
      durationMinutes: map['durationMinutes'] ?? 30,
      pointsReward: map['pointsReward'] ?? 10,
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDaily: map['isDaily'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty.name,
      'durationMinutes': durationMinutes,
      'pointsReward': pointsReward,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDaily': isDaily,
      'imageUrl': imageUrl,
    };
  }

  TestModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    Difficulty? difficulty,
    int? durationMinutes,
    int? pointsReward,
    List<QuestionModel>? questions,
    String? createdBy,
    DateTime? createdAt,
    bool? isDaily,
    String? imageUrl,
  }) {
    return TestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      pointsReward: pointsReward ?? this.pointsReward,
      questions: questions ?? this.questions,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isDaily: isDaily ?? this.isDaily,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class QuestionModel {
  final String id;
  final String text;
  final String? imageUrl;
  final List<String> options;
  final int correctIndex;
  final int timeSeconds;

  const QuestionModel({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.options,
    required this.correctIndex,
    this.timeSeconds = 30,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
      timeSeconds: map['timeSeconds'] ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'options': options,
      'correctIndex': correctIndex,
      'timeSeconds': timeSeconds,
    };
  }
}

class TestResult {
  final String id;
  final String testId;
  final String userId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int pointsEarned;
  final DateTime completedAt;
  final int timeTakenSeconds;

  const TestResult({
    required this.id,
    required this.testId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.pointsEarned,
    required this.completedAt,
    required this.timeTakenSeconds,
  });

  factory TestResult.fromMap(Map<String, dynamic> map, {String? id}) {
    return TestResult(
      id: id ?? map['id'] ?? '',
      testId: map['testId'] ?? '',
      userId: map['userId'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      pointsEarned: map['pointsEarned'] ?? 0,
      completedAt:
          (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testId': testId,
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'pointsEarned': pointsEarned,
      'completedAt': Timestamp.fromDate(completedAt),
      'timeTakenSeconds': timeTakenSeconds,
    };
  }
}
