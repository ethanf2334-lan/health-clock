import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _loading = false;
  bool _appleLoading = false;
  int _countdown = 0;
  bool _agreed = false;

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
    final e164 = phone.startsWith('+') ? phone : '+86$phone';

    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).sendPhoneOtp(e164);
      setState(() => _countdown = 60);
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
    if (!_agreed) {
      _snack('请先阅读并同意用户协议与隐私政策');
      return;
    }
    final phone = _phoneController.text.trim();
    final code = _codeController.text.replaceAll(' ', '').trim();
    if (phone.isEmpty || code.isEmpty) {
      _snack('请输入手机号和验证码');
      return;
    }
    final e164 = phone.startsWith('+') ? phone : '+86$phone';

    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).verifyPhoneOtp(e164, code);
    } catch (e) {
      _snack('登录失败：$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    if (!_agreed) {
      _snack('请先阅读并同意用户协议与隐私政策');
      return;
    }
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

  InputDecoration _fieldDecoration({
    required String hint,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.lightOutline),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: AppColors.lightOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: AppColors.mintDeep.withValues(alpha: 0.65)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _LoginWavePainter()),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppStyles.spacingM,
                AppStyles.spacingM,
                AppStyles.spacingM,
                AppStyles.spacingL + bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppStyles.spacingS),
                  Text(
                    '健康时钟',
                    textAlign: TextAlign.center,
                    style: AppStyles.screenTitle.copyWith(
                      color: AppColors.mintDeep,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingS),
                  Text(
                    'AI 帮你轻松管理个人与家庭健康提醒',
                    textAlign: TextAlign.center,
                    style: AppStyles.footnote.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingM),
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 150,
                      child: CustomPaint(
                        painter: _LoginHeroPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppStyles.spacingM),
                  Material(
                    elevation: 6,
                    shadowColor: Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _fieldDecoration(
                              hint: '请输入手机号',
                              prefixIcon: Icon(
                                Icons.smartphone_outlined,
                                color: Colors.grey.shade600,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _codeController,
                                  keyboardType: TextInputType.number,
                                  decoration: _fieldDecoration(
                                    hint: '请输入验证码',
                                    prefixIcon: Icon(
                                      Icons.verified_user_outlined,
                                      color: Colors.grey.shade600,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: TextButton(
                                  onPressed: (_loading || _countdown > 0)
                                      ? null
                                      : _sendOtp,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    minimumSize: const Size(0, 44),
                                  ),
                                  child: Text(
                                    _countdown > 0 ? '${_countdown}s' : '获取验证码',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _countdown > 0
                                          ? Colors.grey
                                          : AppColors.mintDeep,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7ED9A8),
                                  AppColors.mintDeep,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mintDeep
                                      .withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: (_loading || _appleLoading)
                                    ? null
                                    : _verify,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        '登录 / 注册',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: (_loading || _appleLoading)
                                ? null
                                : _signInWithApple,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: const BorderSide(
                                color: AppColors.lightOutline,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: _appleLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.apple,
                                        size: 22,
                                        color: Colors.black87,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '通过 Apple 登录',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreed,
                                  onChanged: (v) =>
                                      setState(() => _agreed = v ?? false),
                                  fillColor: WidgetStateProperty.resolveWith(
                                    (s) => s.contains(WidgetState.selected)
                                        ? AppColors.mintDeep
                                        : null,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Expanded(child: _agreementText(context)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.mintSoft.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '未注册手机号登录后将自动创建账号',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _agreementText(BuildContext context) {
    final base = TextStyle(
      fontSize: 12,
      color: Colors.grey.shade700,
      height: 1.45,
    );
    const link = TextStyle(
      fontSize: 12,
      color: AppColors.mintDeep,
      fontWeight: FontWeight.w600,
      height: 1.45,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: '登录即表示你已阅读并同意'),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => context.push('/legal/terms'),
              child: const Text('《用户协议》', style: link),
            ),
          ),
          const TextSpan(text: '和'),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => context.push('/legal/privacy'),
              child: const Text('《隐私政策》', style: link),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final paint = Paint()
      ..color = AppColors.mintSoft.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, h * 0.72);
    for (double x = 0; x <= size.width; x += 4) {
      final t = x / size.width * 2 * math.pi;
      final y = h * 0.78 + math.sin(t * 1.2) * 14 + math.sin(t * 2.3) * 6;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, h);
    path.lineTo(0, h);
    path.close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = AppColors.mintBgLight.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    final path2 = Path();
    path2.moveTo(0, h * 0.78);
    for (double x = 0; x <= size.width; x += 4) {
      final t = x / size.width * 2 * math.pi + 1;
      final y = h * 0.84 + math.sin(t) * 18;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, h);
    path2.lineTo(0, h);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void softShadow(Offset o, double r) {
      final p = Paint()
        ..color = Colors.black.withValues(alpha: 0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(o.translate(0, 4), r, p);
    }

    softShadow(Offset(w * 0.22, h * 0.55), 22);
    softShadow(Offset(w * 0.55, h * 0.60), 34);

    final clock = Paint()..color = AppColors.mintDeep;
    canvas.drawCircle(Offset(w * 0.22, h * 0.52), 22, clock);
    final clockInner = Paint()..color = AppColors.mintSoft;
    canvas.drawCircle(Offset(w * 0.22, h * 0.52), 17, clockInner);
    final hand = Paint()
      ..color = AppColors.mintDeep
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final c = Offset(w * 0.22, h * 0.52);
    canvas.drawLine(c, c + const Offset(0, -9), hand);
    canvas.drawLine(c, c + const Offset(7, 2), hand);

    final calRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.55, h * 0.48),
        width: 68,
        height: 58,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      calRect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.06),
    );
    canvas.drawRRect(calRect, Paint()..color = Colors.white);
    final calHead = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(w * 0.55, h * 0.36),
        width: 68,
        height: 22,
      ),
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
    );
    canvas.drawRRect(calHead, Paint()..color = AppColors.mintSoft);
    final tick = Paint()
      ..color = AppColors.mintDeep
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.48, h * 0.50),
      Offset(w * 0.58, h * 0.56),
      tick,
    );
    canvas.drawLine(
      Offset(w * 0.58, h * 0.56),
      Offset(w * 0.64, h * 0.46),
      tick,
    );

    final shieldPath = Path();
    final sx = w * 0.78;
    final sy = h * 0.42;
    const sr = 16.0;
    shieldPath.moveTo(sx, sy - sr);
    shieldPath.quadraticBezierTo(
      sx + sr,
      sy - sr * 0.2,
      sx + sr * 0.95,
      sy + sr * 0.2,
    );
    shieldPath.quadraticBezierTo(sx + sr * 0.9, sy + sr * 0.85, sx, sy + sr);
    shieldPath.quadraticBezierTo(
      sx - sr * 0.9,
      sy + sr * 0.85,
      sx - sr * 0.95,
      sy + sr * 0.2,
    );
    shieldPath.quadraticBezierTo(sx - sr, sy - sr * 0.2, sx, sy - sr);
    shieldPath.close();
    canvas.drawPath(shieldPath, Paint()..color = const Color(0xFFE8F5EC));
    canvas.drawPath(
      shieldPath,
      Paint()
        ..color = AppColors.mintDeep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final cross = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(sx, sy - 5), Offset(sx, sy + 6), cross);
    canvas.drawLine(Offset(sx - 5, sy + 2), Offset(sx + 5, sy + 2), cross);

    final heart = Paint()..color = AppColors.rose;
    final hx = w * 0.38;
    final hy = h * 0.30;
    const hs = 7.0;
    final hp = Path();
    hp.moveTo(hx, hy + hs * 0.65);
    hp.cubicTo(
      hx - hs * 1.1,
      hy,
      hx - hs * 0.5,
      hy - hs * 0.9,
      hx,
      hy - hs * 0.2,
    );
    hp.cubicTo(
      hx + hs * 0.5,
      hy - hs * 0.9,
      hx + hs * 1.1,
      hy,
      hx,
      hy + hs * 0.65,
    );
    canvas.drawPath(hp, heart);

    final leaf = Paint()..color = AppColors.mintDeep.withValues(alpha: 0.45);
    void lf(double x, double y, double r, double rot) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      final p = Path();
      p.moveTo(0, -r);
      p.quadraticBezierTo(r * 0.7, 0, 0, r);
      p.quadraticBezierTo(-r * 0.7, 0, 0, -r);
      canvas.drawPath(p, leaf);
      canvas.restore();
    }

    lf(w * 0.12, h * 0.72, 8, -0.4);
    lf(w * 0.88, h * 0.68, 7, 0.5);
    lf(w * 0.72, h * 0.22, 6, 0.2);

    final fam = Paint()..color = AppColors.mintDeep.withValues(alpha: 0.55);
    canvas.drawCircle(Offset(w * 0.42, h * 0.68), 4.5, fam);
    canvas.drawCircle(Offset(w * 0.52, h * 0.68), 4.5, fam);
    canvas.drawCircle(
      Offset(w * 0.47, h * 0.76),
      3.8,
      Paint()..color = AppColors.warmAmber.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
