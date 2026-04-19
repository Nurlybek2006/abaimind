import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, curator, admin }

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String group;
  final int course;
  final UserRole role;
  final String? avatarUrl;
  final int totalPoints;
  final int completedTests;
  final int streak;
  final int bestStreak;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime lastActive;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.group,
    required this.course,
    required this.role,
    this.avatarUrl,
    this.totalPoints = 0,
    this.completedTests = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.badges = const [],
    required this.createdAt,
    required this.lastActive,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      group: map['group'] ?? '',
      course: map['course'] ?? 1,
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.student,
      ),
      avatarUrl: map['avatarUrl'],
      totalPoints: map['totalPoints'] ?? 0,
      completedTests: map['completedTests'] ?? 0,
      streak: map['streak'] ?? 0,
      bestStreak: map['bestStreak'] ?? 0,
      badges: (map['badges'] is Iterable)
          ? List<String>.from(map['badges'])
          : [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive:
          (map['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // For Firestore — uses Timestamp
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'group': group,
      'course': course,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'totalPoints': totalPoints,
      'completedTests': completedTests,
      'streak': streak,
      'bestStreak': bestStreak,
      'badges': badges,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  // For Hive/JSON — uses milliseconds (no Timestamp)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'group': group,
      'course': course,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'totalPoints': totalPoints,
      'completedTests': completedTests,
      'streak': streak,
      'bestStreak': bestStreak,
      'badges': badges,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastActive': lastActive.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      group: map['group'] ?? '',
      course: map['course'] ?? 1,
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.student,
      ),
      avatarUrl: map['avatarUrl'],
      totalPoints: map['totalPoints'] ?? 0,
      completedTests: map['completedTests'] ?? 0,
      streak: map['streak'] ?? 0,
      bestStreak: map['bestStreak'] ?? 0,
      badges: (map['badges'] is Iterable)
          ? List<String>.from(map['badges'])
          : [],
      createdAt: map['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      lastActive: map['lastActive'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['lastActive'])
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? group,
    int? course,
    UserRole? role,
    String? avatarUrl,
    int? totalPoints,
    int? completedTests,
    int? streak,
    int? bestStreak,
    List<String>? badges,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      group: group ?? this.group,
      course: course ?? this.course,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      completedTests: completedTests ?? this.completedTests,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
