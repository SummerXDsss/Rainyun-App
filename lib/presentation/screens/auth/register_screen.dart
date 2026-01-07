import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_usernameController.text.trim().isEmpty) {
      TDToast.showWarning('请输入用户名', context: context);
      return;
    }
    if (_usernameController.text.length < 2) {
      TDToast.showWarning('用户名至少2位', context: context);
      return;
    }
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
    if (_confirmPasswordController.text.isEmpty) {
      TDToast.showWarning('请再次输入密码', context: context);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      TDToast.showWarning('两次密码输入不一致', context: context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
      );

      if (response.session != null && mounted) {
        TDToast.showSuccess('注册成功', context: context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (mounted) {
        TDToast.showText('注册成功，请查收邮箱验证邮件', context: context);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        TDToast.showFail('注册失败：${e.toString()}', context: context);
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
      appBar: TDNavBar(
        title: '注册',
        leftBarItems: [
          TDNavBarItem(
            icon: TDIcons.chevron_left,
            iconSize: 28,
            action: () => Navigator.of(context).pop(),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                TDInput(
                  controller: _usernameController,
                  type: TDInputType.normal,
                  leftLabel: '用户名',
                  hintText: '请输入用户名',
                  backgroundColor: Colors.white,
                  leftIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 16),
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
                  hintText: '请输入密码（至少6位）',
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
                const SizedBox(height: 16),
                TDInput(
                  controller: _confirmPasswordController,
                  type: TDInputType.normal,
                  leftLabel: '确认密码',
                  hintText: '请再次输入密码',
                  obscureText: _obscureConfirmPassword,
                  backgroundColor: Colors.white,
                  leftIcon: const Icon(Icons.lock_outline),
                  rightBtn: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                const SizedBox(height: 32),
                TDButton(
                  text: '注册',
                  size: TDButtonSize.large,
                  type: TDButtonType.fill,
                  theme: TDButtonTheme.primary,
                  isBlock: true,
                  disabled: _isLoading,
                  onTap: _handleRegister,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TDText(
                    '注册即表示同意雨云用户协议',
                    font: TDTheme.of(context).fontBodySmall,
                    textColor: TDTheme.of(context).fontGyColor3,
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
