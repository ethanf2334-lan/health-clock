import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// 通用成员头像。基于关系生成 emoji 和柔和背景色。
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
    final emoji = _emojiFor(relation, name);
    final bg = _bgFor(relation);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(fontSize: size * 0.55),
      ),
    );
  }

  static String _emojiFor(String? relation, String? name) {
    switch (relation) {
      case 'mother':
        return '👩';
      case 'father':
        return '👨';
      case 'self':
        return '🧑';
      case 'spouse':
        return '💑';
      case 'child':
        return '🧒';
      default:
        if (name == null || name.isEmpty) return '🙂';
        return name.characters.first;
    }
  }

  static Color _bgFor(String? relation) {
    switch (relation) {
      case 'mother':
        return AppColors.roseSoft;
      case 'father':
        return AppColors.careBlueSoft;
      case 'self':
        return AppColors.lavenderSoft;
      case 'spouse':
        return AppColors.mintSoft;
      case 'child':
        return AppColors.sunSoft;
      default:
        return AppColors.mintSoft;
    }
  }
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.mintDeep,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
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
