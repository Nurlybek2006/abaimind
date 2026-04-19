import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import 'auth_provider.dart';

final newsServiceProvider = Provider((ref) => NewsService());

final newsStreamProvider = StreamProvider<List<NewsModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(newsServiceProvider).getNews();
});
