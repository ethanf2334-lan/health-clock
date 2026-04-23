import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '健康时钟',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('手机号登录功能开发中')),
                  );
                },
                child: const Text('手机号登录'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Apple 登录功能开发中')),
                  );
                },
                child: const Text('Apple 登录'),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  // 跳过登录，直接进入主界面
                  context.go('/home');
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('跳过登录（测试模式）'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
