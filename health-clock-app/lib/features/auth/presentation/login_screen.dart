import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;
  bool _appleLoading = false;
  int _countdown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _snack('请输入手机号');
      return;
    }
    // 补齐国际区号（Supabase 要求 E.164）
    final e164 = phone.startsWith('+') ? phone : '+86$phone';

    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).sendPhoneOtp(e164);
      setState(() {
        _codeSent = true;
        _countdown = 60;
      });
      _tickCountdown();
      _snack('验证码已发送');
    } catch (e) {
      _snack('发送失败：$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _tickCountdown() async {
    while (_countdown > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _countdown--);
    }
  }

  Future<void> _verify() async {
    final phone = _phoneController.text.trim();
    // 去掉空格（短信里验证码可能带空格，如 "123 456"）
    final code = _codeController.text.replaceAll(' ', '').trim();
    if (phone.isEmpty || code.isEmpty) {
      _snack('请输入手机号和验证码');
      return;
    }
    final e164 = phone.startsWith('+') ? phone : '+86$phone';

    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).verifyPhoneOtp(e164, code);
      // 路由将由 GoRouter redirect 自动切换
    } catch (e) {
      _snack('登录失败：$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _appleLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithApple();
    } catch (e) {
      _snack('Apple 登录失败：$e');
    } finally {
      if (mounted) setState(() => _appleLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text(
                '健康时钟',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '照看全家的健康',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: '手机号',
                  prefixText: '+86 ',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '验证码'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: (_loading || _countdown > 0) ? null : _sendOtp,
                      child: Text(_countdown > 0 ? '${_countdown}s' : '获取验证码'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (_loading || !_codeSent) ? null : _verify,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('登录'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed:
                    (_loading || _appleLoading) ? null : _signInWithApple,
                icon: const Icon(Icons.apple),
                label: _appleLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('使用 Apple 登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
