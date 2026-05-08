import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// 轻量成员头像：柔和圆形底色 + 角色 emoji。
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.name,
    required this.relation,
    this.size = 44,
    this.borderColor,
    this.borderWidth = 0,
  });

  final String? name;
  final String? relation;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(relation);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.bgTop, style.bgBottom],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.72),
          width: borderColor == null ? 1 : borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: style.fg.withValues(alpha: 0.14),
            blurRadius: size * 0.20,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _emojiFor(relation),
        style: TextStyle(
          fontSize: size * 0.46,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }

  static String _emojiFor(String? relation) {
    switch (relation) {
      case 'self':
        return '🙂';
      case 'father':
        return '👨';
      case 'mother':
        return '👩';
      case 'spouse':
        return '😊';
      case 'child':
        return '🧒';
      default:
        return '🙂';
    }
  }

  static _AvatarStyle _styleFor(String? relation) {
    switch (relation) {
      case 'self':
        return const _AvatarStyle(
          bgTop: Color(0xFFE3F8EA),
          bgBottom: Color(0xFFCFF2DC),
          fg: AppColors.mintDeep,
        );
      case 'father':
        return const _AvatarStyle(
          bgTop: Color(0xFFEAF4FF),
          bgBottom: Color(0xFFDCEEFF),
          fg: Color(0xFF3578C6),
        );
      case 'mother':
        return const _AvatarStyle(
          bgTop: Color(0xFFFFEDF6),
          bgBottom: Color(0xFFFFDDEA),
          fg: Color(0xFFD84E83),
        );
      case 'spouse':
        return const _AvatarStyle(
          bgTop: Color(0xFFE9F7FF),
          bgBottom: Color(0xFFDCEFFF),
          fg: Color(0xFF209966),
        );
      case 'child':
        return const _AvatarStyle(
          bgTop: Color(0xFFFFF5DE),
          bgBottom: Color(0xFFFFE8B8),
          fg: Color(0xFFC77710),
        );
      default:
        return const _AvatarStyle(
          bgTop: Color(0xFFEAF7F0),
          bgBottom: Color(0xFFD9EFE5),
          fg: AppColors.mintDeep,
        );
    }
  }
}

class _AvatarStyle {
  const _AvatarStyle({
    required this.bgTop,
    required this.bgBottom,
    required this.fg,
  });

  final Color bgTop;
  final Color bgBottom;
  final Color fg;
}

/// 头像 + 底部小徽章 (例如 "当前成员")
class MemberAvatarWithBadge extends StatelessWidget {
  const MemberAvatarWithBadge({
    super.key,
    required this.name,
    required this.relation,
    required this.badgeText,
    this.size = 88,
  });

  final String? name;
  final String? relation;
  final String badgeText;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 4,
      height: size + 22,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          MemberAvatar(
            name: name,
            relation: relation,
            size: size,
            borderColor: Colors.white,
            borderWidth: 3,
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.mintDeep,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
