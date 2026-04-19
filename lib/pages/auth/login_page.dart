import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/gold_text_field.dart';
import '../home/home_shell.dart';
import '../home/admin_shell.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(currentUserProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (!mounted) return;

      // Route based on role
      final destination = user.role == UserRole.student
          ? const HomeShell()
          : const AdminShell();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showResetPasswordDialog() async {
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Құпия сөзді қалпына келтіру'),
        content: TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Болдырмау'),
          ),
          TextButton(
            onPressed: () async {
              if (emailCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ref
                    .read(authServiceProvider)
                    .resetPassword(emailCtrl.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Сілтеме поштаңызға жіберілді'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email табылмады'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Жіберу',
                style: TextStyle(color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found') || raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) {
      return 'Email немесе құпия сөз қате';
    }
    if (raw.contains('too-many-requests')) {
      return 'Тым көп әрекет. Кейінірек қайталаңыз';
    }
    if (raw.contains('network-request-failed')) {
      return 'Интернет байланысын тексеріңіз';
    }
    return 'Қате: $raw';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.gold,
                ),
                const SizedBox(height: 32),
                Text(
                  AppStrings.welcome,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.goldDark,
                      ),
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                const SizedBox(height: 8),
                Text(
                  'Аккаунтыңызға кіріңіз',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 48),
                GoldTextField(
                  controller: _emailController,
                  hintText: AppStrings.email,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Электрондық поштаны енгізіңіз';
                    }
                    if (!v.contains('@')) return 'Дұрыс формат емес';
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                const SizedBox(height: 20),
                GoldTextField(
                  controller: _passwordController,
                  hintText: AppStrings.password,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.gold,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Құпия сөзді енгізіңіз';
                    if (v.length < 6) return 'Кемінде 6 символ';
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showResetPasswordDialog,
                    child: const Text(
                      AppStrings.forgotPassword,
                      style: TextStyle(color: AppColors.gold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GoldButton(
                  text: AppStrings.login,
                  isLoading: _isLoading,
                  onPressed: _login,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.noAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: const Text(
                        AppStrings.register,
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
