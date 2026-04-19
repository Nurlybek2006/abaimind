import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_widget.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.gold,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'Апталық'),
              Tab(text: 'Айлық'),
              Tab(text: 'Барлық'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _LeaderboardList(),
              _LeaderboardList(),
              _LeaderboardList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardList extends ConsumerWidget {
  const _LeaderboardList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardStreamProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return leaderboardAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorWidget2(message: e.toString()),
      data: (users) {
        if (users.isEmpty) {
          return const EmptyWidget(
            message: 'Рейтинг жоқ',
            icon: Icons.leaderboard_outlined,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isCurrentUser = user.uid == currentUser?.uid;
            final isTop3 = index < 3;

            return _LeaderboardTile(
              rank: index + 1,
              user: user,
              isCurrentUser: isCurrentUser,
              isTop3: isTop3,
            )
                .animate()
                .fadeIn(delay: (index * 60).ms)
                .slideX(begin: 0.1);
          },
        );
      },
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final UserModel user;
  final bool isCurrentUser;
  final bool isTop3;

  const _LeaderboardTile({
    required this.rank,
    required this.user,
    required this.isCurrentUser,
    required this.isTop3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.gold.withValues(alpha: 0.08)
            : isTop3
                ? AppColors.goldShimmer.withValues(alpha: 0.12)
                : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.gold
              : isTop3
                  ? AppColors.gold.withValues(alpha: 0.3)
                  : Colors.transparent,
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: isTop3
            ? [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: isTop3
                ? _buildMedal()
                : Text(
                    '#$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            decoration: isTop3
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  )
                : null,
            padding: isTop3 ? const EdgeInsets.all(2) : null,
            child: CircleAvatar(
              radius: isTop3 ? 22 : 20,
              backgroundColor: AppColors.gold.withValues(alpha: 0.1),
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: isTop3 ? 18 : 16,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontWeight:
                        isTop3 ? FontWeight.w700 : FontWeight.w500,
                    fontSize: isTop3 ? 16 : 14,
                  ),
                ),
                Text(
                  '${user.group} • ${user.completedTests} тест',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
          // Points
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: isTop3 ? AppColors.goldGradient : null,
              color: isTop3 ? null : AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: 16,
                  color: isTop3 ? AppColors.white : AppColors.gold,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user.totalPoints}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isTop3 ? AppColors.white : AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedal() {
    final colors = [
      [const Color(0xFFFFD700), const Color(0xFFFFA500)], // Gold
      [const Color(0xFFC0C0C0), const Color(0xFF808080)], // Silver
      [const Color(0xFFCD7F32), const Color(0xFF8B4513)], // Bronze
    ];
    final icons = [
      Icons.looks_one_rounded,
      Icons.looks_two_rounded,
      Icons.looks_3_rounded,
    ];

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors[rank - 1]),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors[rank - 1][0].withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icons[rank - 1], color: AppColors.white, size: 22),
    );
  }
}
