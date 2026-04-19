import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/news_model.dart';
import '../../models/user_model.dart';
import '../../providers/news_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gold_card.dart';
import '../../widgets/loading_widget.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsStreamProvider);
    final userAsync = ref.watch(currentUserProvider);
    final isCurator = userAsync.valueOrNull?.role == UserRole.curator ||
        userAsync.valueOrNull?.role == UserRole.admin;

    return Scaffold(
      body: newsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorWidget2(message: e.toString()),
        data: (newsList) {
          if (newsList.isEmpty) {
            return const EmptyWidget(
              message: 'Жаңалықтар жоқ',
              icon: Icons.newspaper_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return _NewsCard(news: news, isCurator: isCurator)
                  .animate()
                  .fadeIn(delay: (index * 100).ms)
                  .slideY(begin: 0.1);
            },
          );
        },
      ),
      floatingActionButton: isCurator
          ? FloatingActionButton(
              onPressed: () => _showAddNewsDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddNewsDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final user = ref.read(currentUserProvider).valueOrNull;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.addNews,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: AppStrings.newsTitle),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration:
                  const InputDecoration(hintText: AppStrings.newsContent),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      contentController.text.isNotEmpty &&
                      user != null) {
                    final news = NewsModel(
                      id: '',
                      title: titleController.text,
                      content: contentController.text,
                      authorId: user.uid,
                      authorName: user.fullName,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(newsServiceProvider).createNews(news);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text(AppStrings.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends ConsumerWidget {
  final NewsModel news;
  final bool isCurator;

  const _NewsCard({required this.news, required this.isCurator});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GoldCard(
      hasBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (news.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                news.imageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          if (news.imageUrl != null) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  news.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (isCurator)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.gold),
                  onSelected: (value) async {
                    if (value == 'delete') {
                      await ref
                          .read(newsServiceProvider)
                          .deleteNews(news.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(AppStrings.deleteNews),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            news.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                news.authorName,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textHint),
              ),
              const Spacer(),
              const Icon(Icons.access_time,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd.MM.yyyy HH:mm').format(news.createdAt),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
