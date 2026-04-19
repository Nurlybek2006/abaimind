import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/hive_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserModel?>>((ref) {
  return CurrentUserNotifier(ref);
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;
  bool _busy = false;

  CurrentUserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    // Check current auth state immediately (handles app restart with existing session)
    final authState = _ref.read(authStateProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          loadUser();
        } else {
          state = const AsyncValue.data(null);
        }
      },
      loading: () {/* wait for listener below */},
      error: (e, s) => state = AsyncValue.error(e, s),
    );

    // Listen for subsequent auth changes (login / logout)
    _ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) {
      next.when(
        data: (user) {
          if (user != null) {
            // Skip if we are in the middle of a manual signIn/register
            if (_busy) return;
            loadUser();
          } else {
            if (_busy) return;
            state = const AsyncValue.data(null);
          }
        },
        loading: () {/* do not override state here */},
        error: (e, s) => state = AsyncValue.error(e, s),
      );
    });
  }

  Future<void> loadUser() async {
    try {
      state = const AsyncValue.loading();
      final user = await _ref.read(authServiceProvider).getCurrentUserModel();
      if (user != null) {
        await HiveService.cacheUser(user.toJson());
        state = AsyncValue.data(user);
      } else {
        // Auth exists but no Firestore doc — sign out
        await _ref.read(authServiceProvider).signOut();
        state = const AsyncValue.data(null);
      }
    } catch (e, s) {
      // Offline fallback: use cached user
      final cached = HiveService.getCachedUser();
      if (cached != null) {
        state = AsyncValue.data(UserModel.fromJson(cached));
      } else {
        // Don't sign out on error — just show error
        state = AsyncValue.error(e, s);
      }
    }
  }

  Future<UserModel> signIn(String email, String password) async {
    _busy = true;
    state = const AsyncValue.loading();
    try {
      final user =
          await _ref.read(authServiceProvider).signIn(email, password);
      await HiveService.cacheUser(user.toJson());
      state = AsyncValue.data(user);
      return user;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    } finally {
      _busy = false;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String group,
    required int course,
  }) async {
    _busy = true;
    state = const AsyncValue.loading();
    try {
      final user = await _ref.read(authServiceProvider).register(
            email: email,
            password: password,
            fullName: fullName,
            group: group,
            course: course,
          );
      await HiveService.cacheUser(user.toJson());
      state = AsyncValue.data(user);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    } finally {
      _busy = false;
    }
  }

  Future<void> signOut() async {
    await _ref.read(authServiceProvider).signOut();
    await HiveService.clearAll();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile(UserModel user) async {
    await _ref.read(authServiceProvider).updateUserProfile(user);
    await HiveService.cacheUser(user.toJson());
    state = AsyncValue.data(user);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(HiveService.getDarkMode());

  void toggle() {
    state = !state;
    HiveService.setDarkMode(state);
  }
}
