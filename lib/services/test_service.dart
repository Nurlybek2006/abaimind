import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/test_model.dart';

class TestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _testsRef => _firestore.collection('tests');
  CollectionReference get _resultsRef => _firestore.collection('test_results');

  Stream<List<TestModel>> getTests() {
    return _testsRef.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  TestModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
              .toList(),
        );
  }

  Stream<List<TestModel>> getTestsByCategory(String category) {
    return _testsRef
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  TestModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
              .toList(),
        );
  }

  Future<TestModel?> getDailyChallenge() async {
    final snapshot = await _testsRef
        .where('isDaily', isEqualTo: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return TestModel.fromMap(
      snapshot.docs.first.data() as Map<String, dynamic>,
      id: snapshot.docs.first.id,
    );
  }

  Future<String> createTest(TestModel test) async {
    final doc = await _testsRef.add(test.toMap());
    return doc.id;
  }

  Future<void> updateTest(TestModel test) async {
    await _testsRef.doc(test.id).update(test.toMap());
  }

  Future<void> deleteTest(String testId) async {
    await _testsRef.doc(testId).delete();
  }

  Future<void> submitResult(TestResult result) async {
    await _resultsRef.doc(result.id).set(result.toMap());

    // Update user points and completed tests
    await _firestore.collection('users').doc(result.userId).update({
      'totalPoints': FieldValue.increment(result.pointsEarned),
      'completedTests': FieldValue.increment(1),
    });
  }

  Stream<List<TestResult>> getUserResults(String userId) {
    return _resultsRef
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  TestResult.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
              .toList(),
        );
  }

  Future<List<String>> getCategories() async {
    final snapshot = await _testsRef.get();
    final categories = snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['category'] as String?)
        .where((c) => c != null)
        .cast<String>()
        .toSet()
        .toList();
    return categories;
  }
}
