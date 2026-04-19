import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/leaderboard_service.dart';
import 'auth_provider.dart';

final leaderboardServiceProvider = Provider((ref) => LeaderboardService());

final leaderboardStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(leaderboardServiceProvider).getLeaderboard();
});
