import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/gold_text_field.dart';
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _groupController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int _course = 1;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _groupController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(currentUserProvider.notifier).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            group: _groupController.text.trim(),
            course: _course,
          );
      // Navigation handled by main.dart via currentUserProvider stream
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

  String _friendlyError(String raw) {
    if (raw.contains('email-already-in-use')) return 'Р‘Т±Р» email С‚С–СЂРєРµР»РіРµРЅ';
    if (raw.contains('weak-password')) return 'ТљТ±РїРёСЏ СЃУ©Р· С‚С‹Рј Т›Р°СЂР°РїР°Р№С‹Рј';
    if (raw.contains('invalid-email')) return 'Email С„РѕСЂРјР°С‚С‹ РґТ±СЂС‹СЃ РµРјРµСЃ';
    if (raw.contains('network-request-failed')) return 'РРЅС‚РµСЂРЅРµС‚ Р±Р°Р№Р»Р°РЅС‹СЃС‹РЅ С‚РµРєСЃРµСЂС–ТЈС–Р·';
    return 'РўС–СЂРєРµР»Сѓ СЃУ™С‚СЃС–Р· Р±РѕР»РґС‹. ТљР°Р№С‚Р°Р»Р°Рї РєУ©СЂС–ТЈС–Р·';
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
                const SizedBox(height: 24),
                Text(
                  AppStrings.register,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.goldDark,
                      ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 8),
                Text(
                  'РЎС‚СѓРґРµРЅС‚ Р°РєРєР°СѓРЅС‚С‹РЅ Р¶Р°СЃР°ТЈС‹Р·',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),
                GoldTextField(
                  controller: _fullNameController,
                  hintText: AppStrings.fullName,
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'РђС‚С‹-Р¶У©РЅС–ТЈС–Р·РґС– РµРЅРіС–Р·С–ТЈС–Р·';
                    }
                    if (v.trim().length < 3) return 'РљРµРјС–РЅРґРµ 3 СЃРёРјРІРѕР»';
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
                GoldTextField(
                  controller: _emailController,
                  hintText: AppStrings.email,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'РџРѕС€С‚Р°РЅС‹ РµРЅРіС–Р·С–ТЈС–Р·';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(v.trim())) {
                      return 'Р”Т±СЂС‹СЃ email С„РѕСЂРјР°С‚С‹ РµРјРµСЃ';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 16),
                GoldTextField(
                  controller: _groupController,
                  hintText: AppStrings.group,
                  prefixIcon: Icons.group_outlined,
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'РўРѕРїС‚С‹ РµРЅРіС–Р·С–ТЈС–Р·' : null,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 16),
                // Course selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _course,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: AppColors.gold),
                      items: [1, 2, 3, 4].map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text('$c-${AppStrings.course}'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _course = v ?? 1),
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 16),
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
                    if (v == null || v.isEmpty) return 'ТљТ±РїРёСЏ СЃУ©Р·РґС– РµРЅРіС–Р·С–ТЈС–Р·';
                    if (v.length < 6) return 'РљРµРјС–РЅРґРµ 6 СЃРёРјРІРѕР»';
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 16),
                GoldTextField(
                  controller: _confirmPasswordController,
                  hintText: AppStrings.confirmPassword,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.gold,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'ТљТ±РїРёСЏ СЃУ©Р·РґРµСЂ СЃУ™Р№РєРµСЃ РєРµР»РјРµР№РґС–';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 550.ms),
                const SizedBox(height: 32),
                GoldButton(
                  text: AppStrings.register,
                  isLoading: _isLoading,
                  onPressed: _register,
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.haveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: const Text(
                        AppStrings.login,
                        style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
