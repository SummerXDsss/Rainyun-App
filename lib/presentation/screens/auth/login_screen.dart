import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty) {
      TDToast.showWarning('请输入邮箱', context: context);
      return;
    }
    if (!_emailController.text.contains('@')) {
      TDToast.showWarning('请输入有效的邮箱', context: context);
      return;
    }
    if (_passwordController.text.isEmpty) {
      TDToast.showWarning('请输入密码', context: context);
      return;
    }
    if (_passwordController.text.length < 6) {
      TDToast.showWarning('密码至少6位', context: context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.session != null && mounted) {
        TDToast.showSuccess('登录成功', context: context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        TDToast.showFail('登录失败：${e.toString()}', context: context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TDTheme.of(context).whiteColor1,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 24),
                TDText(
                  '欢迎回来',
                  font: TDTheme.of(context).fontTitleLarge,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TDText(
                  '使用 Supabase 账号登录',
                  font: TDTheme.of(context).fontBodyMedium,
                  textColor: TDTheme.of(context).fontGyColor3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TDInput(
                  controller: _emailController,
                  type: TDInputType.normal,
                  leftLabel: '邮箱',
                  hintText: '请输入邮箱',
                  backgroundColor: Colors.white,
                  leftIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 16),
                TDInput(
                  controller: _passwordController,
                  type: TDInputType.normal,
                  leftLabel: '密码',
                  hintText: '请输入密码',
                  obscureText: _obscurePassword,
                  backgroundColor: Colors.white,
                  leftIcon: const Icon(Icons.lock_outline),
                  rightBtn: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                TDButton(
                  text: '登录',
                  size: TDButtonSize.large,
                  type: TDButtonType.fill,
                  theme: TDButtonTheme.primary,
                  isBlock: true,
                  disabled: _isLoading,
                  onTap: _handleLogin,
                ),
                const SizedBox(height: 16),
                TDButton(
                  text: '注册新账号',
                  size: TDButtonSize.large,
                  type: TDButtonType.outline,
                  theme: TDButtonTheme.primary,
                  isBlock: true,
                  disabled: _isLoading,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      TDToast.showText('功能开发中', context: context);
                    },
                    child: const Text('忘记密码？'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
