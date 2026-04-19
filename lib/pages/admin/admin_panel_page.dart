import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/test_model.dart';
import '../../models/news_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/test_provider.dart';
import '../../providers/news_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../widgets/gold_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/gold_text_field.dart';
import '../../widgets/loading_widget.dart';

class AdminPanelPage extends ConsumerStatefulWidget {
  const AdminPanelPage({super.key});

  @override
  ConsumerState<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends ConsumerState<AdminPanelPage> {
  int _selectedSection = 0;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    // Role guard: only curator and admin can access
    if (user == null || user.role == UserRole.student) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block_rounded, size: 64, color: AppColors.error),
              SizedBox(height: 16),
              Text('Рұқсат жоқ', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminPanel),
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 600)
            NavigationRail(
              selectedIndex: _selectedSection,
              onDestinationSelected: (i) =>
                  setState(() => _selectedSection = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Theme.of(context).cardColor,
              selectedIconTheme: const IconThemeData(color: AppColors.gold),
              selectedLabelTextStyle: const TextStyle(color: AppColors.gold),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Басқару'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.quiz_outlined),
                  selectedIcon: Icon(Icons.quiz),
                  label: Text('Тесттер'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.newspaper_outlined),
                  selectedIcon: Icon(Icons.newspaper),
                  label: Text('Жаңалықтар'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Қолданушылар'),
                ),
              ],
            ),
          Expanded(
            child: _buildSection(),
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 600
          ? BottomNavigationBar(
              currentIndex: _selectedSection,
              onTap: (i) => setState(() => _selectedSection = i),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Басқару',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.quiz_outlined),
                  activeIcon: Icon(Icons.quiz),
                  label: 'Тесттер',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.newspaper_outlined),
                  activeIcon: Icon(Icons.newspaper),
                  label: 'Жаңалықтар',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Қолданушылар',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildSection() {
    switch (_selectedSection) {
      case 0:
        return const _DashboardSection();
      case 1:
        return const _ManageTestsSection();
      case 2:
        return const _ManageNewsSection();
      case 3:
        return const _ManageUsersSection();
      default:
        return const _DashboardSection();
    }
  }
}

// ─── Dashboard Section ───────────────────────────────────────────────────────

class _DashboardSection extends ConsumerWidget {
  const _DashboardSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(testsStreamProvider);
    final usersAsync = ref.watch(leaderboardStreamProvider);
    final newsAsync = ref.watch(newsStreamProvider);

    final testCount = testsAsync.valueOrNull?.length ?? 0;
    final userCount = usersAsync.valueOrNull?.length ?? 0;
    final newsCount = newsAsync.valueOrNull?.length ?? 0;
    final users = usersAsync.valueOrNull ?? [];

    final totalPoints = users.fold<int>(0, (sum, u) => sum + u.totalPoints);
    final totalCompletedTests =
        users.fold<int>(0, (sum, u) => sum + u.completedTests);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dashboard,
            style: Theme.of(context).textTheme.headlineLarge,
          ).animate().fadeIn(),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatCard(
                label: AppStrings.totalStudents,
                value: '$userCount',
                icon: Icons.people_rounded,
                iconColor: AppColors.info,
              ),
              StatCard(
                label: AppStrings.totalTests,
                value: '$testCount',
                icon: Icons.quiz_rounded,
                iconColor: AppColors.gold,
              ),
              StatCard(
                label: 'Жаңалықтар',
                value: '$newsCount',
                icon: Icons.newspaper_rounded,
                iconColor: AppColors.success,
              ),
              StatCard(
                label: 'Тапсырылған тесттер',
                value: '$totalCompletedTests',
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.warning,
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          Text(
            AppStrings.statistics,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          GoldCard(
            hasBorder: true,
            child: Column(
              children: [
                _StatRow(
                  icon: Icons.stars_rounded,
                  label: 'Жалпы ұпай',
                  value: '$totalPoints',
                  color: AppColors.gold,
                ),
                const Divider(height: 1),
                _StatRow(
                  icon: Icons.school_rounded,
                  label: 'Орташа ұпай',
                  value: userCount > 0
                      ? '${(totalPoints / userCount).round()}'
                      : '0',
                  color: AppColors.info,
                ),
                const Divider(height: 1),
                _StatRow(
                  icon: Icons.trending_up_rounded,
                  label: 'Ең жоғары ұпай',
                  value: users.isNotEmpty
                      ? '${users.map((u) => u.totalPoints).reduce((a, b) => a > b ? a : b)}'
                      : '0',
                  color: AppColors.success,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 24),
          if (users.isNotEmpty) ...[
            Text(
              AppStrings.topStudents,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...() {
              final sorted = List<UserModel>.from(users)
                ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
              final count = sorted.length > 5 ? 5 : sorted.length;
              return List.generate(count, (i) {
                final student = sorted[i];
                return GoldCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: i == 0
                          ? AppColors.gold
                          : i == 1
                              ? const Color(0xFFC0C0C0)
                              : i == 2
                                  ? const Color(0xFFCD7F32)
                                  : AppColors.gold.withValues(alpha: 0.1),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i < 3 ? AppColors.white : AppColors.gold,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(student.fullName),
                    subtitle: Text(student.group),
                    trailing: Text(
                      '${student.totalPoints} ұпай',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              });
            }(),
          ],
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Manage Tests Section ────────────────────────────────────────────────────

class _ManageTestsSection extends ConsumerWidget {
  const _ManageTestsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(testsStreamProvider);

    return Scaffold(
      body: testsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorWidget2(message: e.toString()),
        data: (tests) {
          if (tests.isEmpty) {
            return const EmptyWidget(
              message: 'Тесттер жоқ. Жаңа тест құрыңыз.',
              icon: Icons.quiz_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              return GoldCard(
                hasBorder: true,
                onTap: () => _showManageQuestionsPage(context, ref, test),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.quiz, color: AppColors.white),
                  ),
                  title: Text(test.title),
                  subtitle: Text(
                      '${test.questions.length} сұрақ • ${test.pointsReward} ұпай'),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.gold),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showEditTestDialog(context, ref, test);
                      } else if (value == 'questions') {
                        _showManageQuestionsPage(context, ref, test);
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text(AppStrings.deleteTest),
                            content: const Text(AppStrings.areYouSure),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text(AppStrings.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(AppStrings.delete,
                                    style: const TextStyle(
                                        color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(testServiceProvider)
                              .deleteTest(test.id);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text(AppStrings.editTest),
                      ),
                      const PopupMenuItem(
                        value: 'questions',
                        child: Text('Сұрақтарды басқару'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(AppStrings.deleteTest,
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTestDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.createTest),
      ),
    );
  }

  void _showCreateTestDialog(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _CreateTestPage(),
      ),
    );
  }

  void _showEditTestDialog(
      BuildContext context, WidgetRef ref, TestModel test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CreateTestPage(existingTest: test),
      ),
    );
  }

  void _showManageQuestionsPage(
      BuildContext context, WidgetRef ref, TestModel test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ManageQuestionsPage(test: test),
      ),
    );
  }
}

// ─── Create/Edit Test Page ───────────────────────────────────────────────────

class _CreateTestPage extends ConsumerStatefulWidget {
  final TestModel? existingTest;

  const _CreateTestPage({this.existingTest});

  @override
  ConsumerState<_CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends ConsumerState<_CreateTestPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _categoryController;
  late final TextEditingController _pointsController;
  late final TextEditingController _durationController;
  late String _difficulty;
  late List<QuestionModel> _questions;
  bool _isLoading = false;

  bool get isEditing => widget.existingTest != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTest;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _categoryController = TextEditingController(text: t?.category ?? '');
    _pointsController =
        TextEditingController(text: '${t?.pointsReward ?? 10}');
    _durationController =
        TextEditingController(text: '${t?.durationMinutes ?? 30}');
    _difficulty = t?.difficulty.name ?? 'medium';
    _questions = List<QuestionModel>.from(t?.questions ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _pointsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveTest() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final test = TestModel(
        id: widget.existingTest?.id ?? '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _categoryController.text.trim(),
        difficulty: Difficulty.values.firstWhere(
          (d) => d.name == _difficulty,
          orElse: () => Difficulty.medium,
        ),
        durationMinutes: int.tryParse(_durationController.text) ?? 30,
        pointsReward: int.tryParse(_pointsController.text) ?? 10,
        questions: _questions,
        createdBy: widget.existingTest?.createdBy ?? user.uid,
        createdAt: widget.existingTest?.createdAt ?? DateTime.now(),
      );

      if (isEditing) {
        await ref.read(testServiceProvider).updateTest(test);
      } else {
        await ref.read(testServiceProvider).createTest(test);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Тест жаңартылды' : 'Тест құрылды'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addQuestion() {
    _showQuestionDialog(null, null);
  }

  void _editQuestion(int index) {
    _showQuestionDialog(_questions[index], index);
  }

  void _deleteQuestion(int index) {
    setState(() => _questions.removeAt(index));
  }

  void _showQuestionDialog(QuestionModel? existing, int? editIndex) {
    final textController = TextEditingController(text: existing?.text ?? '');
    final optionControllers = List.generate(
      4,
      (i) => TextEditingController(
        text: (existing != null && i < existing.options.length)
            ? existing.options[i]
            : '',
      ),
    );
    int correctIndex = existing?.correctIndex ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
              existing != null ? 'Сұрақты өзгерту' : AppStrings.addQuestion),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GoldTextField(
                  controller: textController,
                  hintText: 'Сұрақ мәтіні',
                  prefixIcon: Icons.help_outline,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ...List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: correctIndex,
                          activeColor: AppColors.gold,
                          onChanged: (v) {
                            setDialogState(() => correctIndex = v ?? 0);
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: optionControllers[i],
                            decoration: InputDecoration(
                              hintText: '${String.fromCharCode(65 + i)} нұсқа',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Text(
                  'Дұрыс жауапты радио батырмамен таңдаңыз',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final questionText = textController.text.trim();
                final options =
                    optionControllers.map((c) => c.text.trim()).toList();

                if (questionText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Сұрақ мәтінін жазыңыз')),
                  );
                  return;
                }

                final filledOptions =
                    options.where((o) => o.isNotEmpty).toList();
                if (filledOptions.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Кемінде 2 нұсқа жазыңыз')),
                  );
                  return;
                }

                if (correctIndex >= filledOptions.length) {
                  correctIndex = 0;
                }

                final question = QuestionModel(
                  id: existing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  text: questionText,
                  options: filledOptions,
                  correctIndex: correctIndex,
                );

                setState(() {
                  if (editIndex != null) {
                    _questions[editIndex] = question;
                  } else {
                    _questions.add(question);
                  }
                });

                Navigator.pop(ctx);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editTest : AppStrings.createTest),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GoldTextField(
                controller: _titleController,
                hintText: 'Тест атауы',
                prefixIcon: Icons.title,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Атауын жазыңыз' : null,
              ),
              const SizedBox(height: 12),
              GoldTextField(
                controller: _descController,
                hintText: 'Сипаттамасы',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              GoldTextField(
                controller: _categoryController,
                hintText: AppStrings.category,
                prefixIcon: Icons.category_outlined,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GoldTextField(
                      controller: _pointsController,
                      hintText: AppStrings.points,
                      prefixIcon: Icons.stars,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GoldTextField(
                      controller: _durationController,
                      hintText: '${AppStrings.duration} (мин)',
                      prefixIcon: Icons.timer,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(
                  labelText: AppStrings.difficulty,
                  prefixIcon: Icon(Icons.speed, color: AppColors.gold),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'easy', child: Text(AppStrings.easy)),
                  DropdownMenuItem(
                      value: 'medium', child: Text(AppStrings.medium)),
                  DropdownMenuItem(
                      value: 'hard', child: Text(AppStrings.hard)),
                ],
                onChanged: (v) =>
                    setState(() => _difficulty = v ?? 'medium'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${AppStrings.questions} (${_questions.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(AppStrings.addQuestion),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_questions.isEmpty)
                GoldCard(
                  hasBorder: true,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.help_outline,
                              size: 48,
                              color: AppColors.gold.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'Сұрақтар жоқ. "Сұрақ қосу" батырмасын басыңыз.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(_questions.length, (i) {
                  final q = _questions[i];
                  return GoldCard(
                    hasBorder: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                q.text,
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: AppColors.gold, size: 20),
                              onPressed: () => _editQuestion(i),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.error, size: 20),
                              onPressed: () => _deleteQuestion(i),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(q.options.length, (oi) {
                          final isCorrect = oi == q.correctIndex;
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 44, bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 16,
                                  color: isCorrect
                                      ? AppColors.success
                                      : AppColors.textHint,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    q.options[oi],
                                    style: TextStyle(
                                      color: isCorrect
                                          ? AppColors.success
                                          : null,
                                      fontWeight: isCorrect
                                          ? FontWeight.w600
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 32),
              GoldButton(
                text: isEditing ? AppStrings.save : AppStrings.createTest,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _saveTest,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Manage Questions Page (for existing test) ──────────────────────────────

class _ManageQuestionsPage extends ConsumerStatefulWidget {
  final TestModel test;

  const _ManageQuestionsPage({required this.test});

  @override
  ConsumerState<_ManageQuestionsPage> createState() =>
      _ManageQuestionsPageState();
}

class _ManageQuestionsPageState extends ConsumerState<_ManageQuestionsPage> {
  late List<QuestionModel> _questions;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _questions = List<QuestionModel>.from(widget.test.questions);
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final updated = widget.test.copyWith(questions: _questions);
      await ref.read(testServiceProvider).updateTest(updated);
      _hasChanges = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сұрақтар сақталды'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addQuestion() {
    _showQuestionDialog(null, null);
  }

  void _editQuestion(int index) {
    _showQuestionDialog(_questions[index], index);
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      _hasChanges = true;
    });
  }

  void _showQuestionDialog(QuestionModel? existing, int? editIndex) {
    final textController = TextEditingController(text: existing?.text ?? '');
    final optionControllers = List.generate(
      4,
      (i) => TextEditingController(
        text: (existing != null && i < existing.options.length)
            ? existing.options[i]
            : '',
      ),
    );
    int correctIndex = existing?.correctIndex ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
              existing != null ? 'Сұрақты өзгерту' : AppStrings.addQuestion),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GoldTextField(
                  controller: textController,
                  hintText: 'Сұрақ мәтіні',
                  prefixIcon: Icons.help_outline,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ...List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: correctIndex,
                          activeColor: AppColors.gold,
                          onChanged: (v) {
                            setDialogState(() => correctIndex = v ?? 0);
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: optionControllers[i],
                            decoration: InputDecoration(
                              hintText: '${String.fromCharCode(65 + i)} нұсқа',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Text(
                  'Дұрыс жауапты радио батырмамен таңдаңыз',
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final questionText = textController.text.trim();
                final options =
                    optionControllers.map((c) => c.text.trim()).toList();

                if (questionText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Сұрақ мәтінін жазыңыз')),
                  );
                  return;
                }

                final filledOptions =
                    options.where((o) => o.isNotEmpty).toList();
                if (filledOptions.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Кемінде 2 нұсқа жазыңыз')),
                  );
                  return;
                }

                if (correctIndex >= filledOptions.length) {
                  correctIndex = 0;
                }

                final question = QuestionModel(
                  id: existing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  text: questionText,
                  options: filledOptions,
                  correctIndex: correctIndex,
                );

                setState(() {
                  if (editIndex != null) {
                    _questions[editIndex] = question;
                  } else {
                    _questions.add(question);
                  }
                  _hasChanges = true;
                });

                Navigator.pop(ctx);
              },
              child: const Text(AppStrings.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.test.title} - Сұрақтар'),
        actions: [
          if (_hasChanges)
            TextButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text(AppStrings.save),
            ),
        ],
      ),
      body: _questions.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.help_outline,
                      size: 64,
                      color: AppColors.gold.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('Сұрақтар жоқ'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addQuestion),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _questions.removeAt(oldIndex);
                  _questions.insert(newIndex, item);
                  _hasChanges = true;
                });
              },
              itemBuilder: (context, i) {
                final q = _questions[i];
                return GoldCard(
                  key: ValueKey(q.id),
                  hasBorder: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.text,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: AppColors.gold, size: 20),
                            onPressed: () => _editQuestion(i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error, size: 20),
                            onPressed: () => _deleteQuestion(i),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(q.options.length, (oi) {
                        final isCorrect = oi == q.correctIndex;
                        return Padding(
                          padding: const EdgeInsets.only(left: 44, bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                isCorrect
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                size: 16,
                                color: isCorrect
                                    ? AppColors.success
                                    : AppColors.textHint,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  q.options[oi],
                                  style: TextStyle(
                                    color:
                                        isCorrect ? AppColors.success : null,
                                    fontWeight:
                                        isCorrect ? FontWeight.w600 : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestion,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ─── Manage News Section ─────────────────────────────────────────────────────

class _ManageNewsSection extends ConsumerWidget {
  const _ManageNewsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsStreamProvider);

    return Scaffold(
      body: newsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorWidget2(message: e.toString()),
        data: (newsList) {
          if (newsList.isEmpty) {
            return const EmptyWidget(
              message: 'Жаңалықтар жоқ. Жаңалық қосыңыз.',
              icon: Icons.newspaper_outlined,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              return GoldCard(
                hasBorder: true,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.article, color: AppColors.white),
                  ),
                  title: Text(news.title),
                  subtitle: Text(news.authorName),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.gold),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _showEditNewsDialog(context, ref, news);
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text(AppStrings.deleteNews),
                            content: const Text(AppStrings.areYouSure),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text(AppStrings.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(AppStrings.delete,
                                    style: const TextStyle(
                                        color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(newsServiceProvider)
                              .deleteNews(news.id);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text(AppStrings.editNews),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(AppStrings.deleteNews,
                            style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNewsDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addNews),
      ),
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
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
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
                  style: Theme.of(sheetContext).textTheme.headlineMedium),
              const SizedBox(height: 20),
              GoldTextField(
                controller: titleController,
                hintText: AppStrings.newsTitle,
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 16),
              GoldTextField(
                controller: contentController,
                hintText: AppStrings.newsContent,
                prefixIcon: Icons.article_outlined,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              GoldButton(
                text: AppStrings.save,
                onPressed: () async {
                  if (titleController.text.trim().isNotEmpty &&
                      contentController.text.trim().isNotEmpty &&
                      user != null) {
                    final news = NewsModel(
                      id: '',
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      authorId: user.uid,
                      authorName: user.fullName,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(newsServiceProvider).createNews(news);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNewsDialog(
      BuildContext context, WidgetRef ref, NewsModel news) {
    final titleController = TextEditingController(text: news.title);
    final contentController = TextEditingController(text: news.content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
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
              Text(AppStrings.editNews,
                  style: Theme.of(sheetContext).textTheme.headlineMedium),
              const SizedBox(height: 20),
              GoldTextField(
                controller: titleController,
                hintText: AppStrings.newsTitle,
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 16),
              GoldTextField(
                controller: contentController,
                hintText: AppStrings.newsContent,
                prefixIcon: Icons.article_outlined,
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              GoldButton(
                text: AppStrings.save,
                onPressed: () async {
                  if (titleController.text.trim().isNotEmpty &&
                      contentController.text.trim().isNotEmpty) {
                    final updated = news.copyWith(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      updatedAt: DateTime.now(),
                    );
                    await ref.read(newsServiceProvider).updateNews(updated);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Manage Users Section ────────────────────────────────────────────────────

class _ManageUsersSection extends ConsumerWidget {
  const _ManageUsersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(leaderboardStreamProvider);

    return usersAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorWidget2(message: e.toString()),
      data: (users) {
        if (users.isEmpty) {
          return const EmptyWidget(
            message: 'Қолданушылар жоқ',
            icon: Icons.people_outline,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return GoldCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.gold.withValues(alpha: 0.1),
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(user.fullName),
                subtitle: Text(
                    '${user.group} • ${user.totalPoints} ұпай • ${user.completedTests} тест'),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getRoleLabel(user.role),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getRoleColor(user.role),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.curator:
        return AppColors.info;
      case UserRole.student:
        return AppColors.gold;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppStrings.admin;
      case UserRole.curator:
        return AppStrings.curator;
      case UserRole.student:
        return AppStrings.student;
    }
  }
}
