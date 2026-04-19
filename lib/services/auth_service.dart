import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Auto-create a student record for users who registered before Firestore was set up
        final user = UserModel(
          uid: credential.user!.uid,
          fullName: credential.user!.displayName ?? email.split('@').first,
          email: email.trim(),
          group: '',
          course: 1,
          role: UserRole.student,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toMap());
        return user;
      }

      await _firestore.collection('users').doc(credential.user!.uid).update({
        'lastActive': Timestamp.now(),
      });
      return UserModel.fromMap(userDoc.data()!);
    } catch (e) {
      // Firestore failed — sign out to prevent broken state
      await _auth.signOut();
      rethrow;
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String group,
    required int course,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      fullName: fullName,
      email: email.trim(),
      group: group,
      course: course,
      role: UserRole.student,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    try {
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());
      return user;
    } catch (e) {
      // Firestore failed — rollback: delete the Auth user
      await credential.user!.delete();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }
}
