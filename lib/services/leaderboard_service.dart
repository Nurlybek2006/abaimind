import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getLeaderboard({int limit = 50}) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.student.name)
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<List<UserModel>> getWeeklyLeaderboard() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.student.name)
        .orderBy('totalPoints', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }

  Future<List<UserModel>> getMonthlyLeaderboard() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.student.name)
        .orderBy('totalPoints', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }
}
