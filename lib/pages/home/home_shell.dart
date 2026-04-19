import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/premium_app_bar.dart';
import '../tests/test_list_page.dart';
import '../news/news_page.dart';
import '../chat/chat_page.dart';
import '../leaderboard/leaderboard_page.dart';
import '../profile/profile_page.dart';

/// Shell for student users only.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  static const _pages = [
    TestListPage(),
    NewsPage(),
    ChatPage(),
    LeaderboardPage(),
    ProfilePage(),
  ];

  static const _titles = [
    AppStrings.tests,
    AppStrings.news,
    AppStrings.curatorChat,
    AppStrings.leaderboard,
    AppStrings.profile,
  ];

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    // Extra safety guard — non-students must not use this shell
    if (user != null && user.role != UserRole.student) {
      return const _UnauthorizedScreen();
    }

    return Scaffold(
      appBar: PremiumAppBar(title: _titles[_currentIndex]),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz_outlined),
              activeIcon: Icon(Icons.quiz),
              label: AppStrings.tests,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              activeIcon: Icon(Icons.newspaper),
              label: AppStrings.news,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: AppStrings.chat,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: AppStrings.leaderboard,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }
}

class _UnauthorizedScreen extends StatelessWidget {
  const _UnauthorizedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block_rounded, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Рұқсат жоқ',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
