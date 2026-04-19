import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_model.dart';

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _newsRef => _firestore.collection('news');

  Stream<List<NewsModel>> getNews() {
    return _newsRef.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  NewsModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
              .toList(),
        );
  }

  Future<String> createNews(NewsModel news) async {
    final doc = await _newsRef.add(news.toMap());
    return doc.id;
  }

  Future<void> updateNews(NewsModel news) async {
    await _newsRef.doc(news.id).update(news.toMap());
  }

  Future<void> deleteNews(String newsId) async {
    await _newsRef.doc(newsId).delete();
  }
}
