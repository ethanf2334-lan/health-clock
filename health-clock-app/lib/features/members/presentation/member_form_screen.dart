import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_styles.dart';
import '../../../shared/models/member.dart';
import '../../../shared/widgets/app_cupertino_pickers.dart';
import '../data/member_repository.dart';
import '../providers/current_member_provider.dart';
import '../providers/member_provider.dart';
import 'widgets/member_avatar.dart';

class MemberFormScreen extends ConsumerStatefulWidget {
  final Member? member;

  const MemberFormScreen({super.key, this.member});

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;

  String _relation = 'self';
  String _gender = 'male';
  DateTime? _birthDate;
  bool _setAsCurrent = true;
  bool _isLoading = false;

  static const _green = Color(0xFF14A85A);
  static const _greenDeep = Color(0xFF138956);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _phoneController = TextEditingController();
    _notesController = TextEditingController(text: widget.member?.notes ?? '');
    _relation = widget.member?.relation ?? 'self';
    _gender = widget.member?.gender ?? 'male';
    _birthDate = widget.member?.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: false,
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar(context)),
                SliverToBoxAdapter(child: _buildHero()),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    AppStyles.spacingM,
                    0,
                    AppStyles.spacingM,
                    AppStyles.spacingM + bottomInset,
                  ),
                  sliver: SliverList.list(
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: AppStyles.spacingS),
                      _buildCurrentMemberCard(),
                      const SizedBox(height: AppStyles.spacingS),
                      _buildPrimaryButton(),
                      const SizedBox(height: AppStyles.spacingM),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final title = widget.member == null ? '添加家庭成员' : '编辑家庭成员';
    final subtitle =
        widget.member == null ? '为家人建立独立的健康提醒与健康档案' : '更新成员健康档案与提醒信息';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.spacingM,
        AppStyles.spacingS,
        AppStyles.spacingM,
        0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.chevron_left_rounded,
                size: 28,
                color: AppColors.textPrimary,
              ),
              style: IconButton.styleFrom(
                minimumSize: const Size(
                  AppStyles.minTouchTarget,
                  AppStyles.minTouchTarget,
                ),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppStyles.screenTitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppStyles.spacingXs),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.caption1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 34,
            right: 24,
            bottom: 10,
            child: SizedBox(
              height: 52,
              child: CustomPaint(painter: _FamilyBackdropPainter()),
            ),
          ),
          Positioned(
            top: 8,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .08),
                        blurRadius: 14,
                        offset: const Offset(0, AppStyles.spacingS),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(7),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE8F4FF), Color(0xFFD4ECFF)],
                      ),
                    ),
                    child: MemberAvatar(
                      name: _nameController.text.trim().isEmpty
                          ? '成员'
                          : _nameController.text.trim(),
                      relation: _relation,
                      size: 70,
                    ),
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF42B87B),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .12),
                          blurRadius: 10,
                          offset: const Offset(0, AppStyles.spacingXs),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: _cardDecoration(radius: 20),
      child: Column(
        children: [
          _textRow(
            label: '成员姓名',
            controller: _nameController,
            hint: '请输入成员姓名',
            validator: (value) =>
                value == null || value.trim().isEmpty ? '请输入成员姓名' : null,
          ),
          const _ThinDivider(),
          _relationRow(),
          const _ThinDivider(horizontal: AppStyles.spacingM),
          _genderRow(),
          const _ThinDivider(),
          _dateRow(),
          const _ThinDivider(),
          _textRow(
            label: '手机号（选填）',
            controller: _phoneController,
            hint: '请输入手机号',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
            ],
          ),
          const _ThinDivider(),
          _textRow(
            label: '备注（选填）',
            controller: _notesController,
            hint: '请输入备注信息',
          ),
        ],
      ),
    );
  }

  Widget _textRow({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.spacingM,
        AppStyles.spacingS,
        AppStyles.spacingM,
        AppStyles.spacingS,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                filled: false,
                fillColor: Colors.transparent,
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                errorStyle: const TextStyle(height: .8, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _relationRow() {
    const items = [
      ('self', '本人'),
      ('father', '父亲'),
      ('mother', '母亲'),
      ('spouse', '配偶'),
      ('child', '子女'),
      ('other', '其他'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.spacingM,
        AppStyles.spacingS,
        AppStyles.spacingM,
        AppStyles.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 64,
            child: Padding(
              padding: EdgeInsets.only(top: 7),
              child: Text(
                '关系',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth =
                    (constraints.maxWidth - AppStyles.spacingS * 2) / 3;
                return Wrap(
                  spacing: AppStyles.spacingS,
                  runSpacing: AppStyles.spacingS,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: itemWidth,
                        child: _ChoicePill(
                          label: item.$2,
                          selected: _relation == item.$1,
                          color: item.$1 == 'child'
                              ? const Color(0xFFFF982F)
                              : _greenDeep,
                          onTap: () => setState(() => _relation = item.$1),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppStyles.spacingM,
        AppStyles.spacingS,
        AppStyles.spacingM,
        AppStyles.spacingS,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '性别',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _SegmentedGender(
            value: _gender,
            onChanged: (value) => setState(() => _gender = value),
          ),
        ],
      ),
    );
  }

  Widget _dateRow() {
    final value = _birthDate == null
        ? '选择日期或输入年龄'
        : DateFormat('yyyy/MM/dd').format(_birthDate!);

    return InkWell(
      onTap: _pickBirthDate,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppStyles.spacingM,
          AppStyles.spacingS,
          AppStyles.spacingM,
          AppStyles.spacingS,
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                '出生日期或年龄',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _birthDate == null
                      ? AppColors.textTertiary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMemberCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacingM,
        vertical: AppStyles.spacingS,
      ),
      decoration: _cardDecoration(radius: AppStyles.radiusL),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '设为当前成员',
              style: AppStyles.subhead.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Transform.scale(
            scale: 1.08,
            child: Switch.adaptive(
              value: _setAsCurrent,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF39B77A),
              inactiveTrackColor: const Color(0xFFE8EEF0),
              onChanged: (value) => setState(() => _setAsCurrent = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          gradient: const LinearGradient(
            colors: [Color(0xFF43C181), Color(0xFF13A85A)],
          ),
          boxShadow: [
            BoxShadow(
              color: _green.withValues(alpha: .22),
              blurRadius: 18,
              offset: const Offset(0, AppStyles.spacingS),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.member == null ? '保存添加' : '保存修改',
                  style: AppStyles.subhead.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration({required double radius}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(color: Colors.white.withValues(alpha: .9)),
    );
  }

  Future<void> _pickBirthDate() async {
    final date = await AppCupertinoPickers.date(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      minimumDate: DateTime(1900),
      maximumDate: DateTime.now(),
      title: '选择出生日期',
    );
    if (date != null && mounted) {
      setState(() => _birthDate = date);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(memberRepositoryProvider);
      Member savedMember;
      if (widget.member != null) {
        final updates = <String, dynamic>{
          'name': _nameController.text.trim(),
          'relation': _relation,
          'gender': _gender,
          'birth_date': _birthDate?.toIso8601String().split('T').first,
          'notes': _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        };
        savedMember = await repo.updateMember(widget.member!.id, updates);
        await ref.read(memberListProvider.notifier).refresh();
      } else {
        savedMember = await repo.createMember(
          MemberCreate(
            name: _nameController.text.trim(),
            relation: _relation,
            gender: _gender,
            birthDate: _birthDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          ),
        );
        await ref.read(memberListProvider.notifier).refresh();
      }

      if (_setAsCurrent) {
        ref.read(currentMemberIdProvider.notifier).state = savedMember.id;
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('保存成功')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('保存失败: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider({this.horizontal = 0});

  final double horizontal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: const Divider(height: 1, thickness: 1, color: Color(0xFFEAF0EC)),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 32,
        constraints: const BoxConstraints(minWidth: 64),
        padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingM),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              selected ? color.withValues(alpha: .09) : const Color(0xFFF6F7F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color.withValues(alpha: .45) : Colors.transparent,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: .08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SegmentedGender extends StatelessWidget {
  const _SegmentedGender({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE7ECE9)),
      ),
      child: Row(
        children: [
          _GenderButton(
            label: '男',
            selected: value == 'male',
            onTap: () => onChanged('male'),
          ),
          _GenderButton(
            label: '女',
            selected: value == 'female',
            onTap: () => onChanged('female'),
          ),
        ],
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF2FCF7) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF7DD9B0) : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color:
                  selected ? const Color(0xFF148956) : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FamilyBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final green = Paint()
      ..color = const Color(0xFF9CE4BD).withValues(alpha: .25)
      ..style = PaintingStyle.fill;
    final darker = Paint()
      ..color = const Color(0xFF5BC48D).withValues(alpha: .16)
      ..style = PaintingStyle.fill;
    final coral = Paint()
      ..color = const Color(0xFFFFB8B5).withValues(alpha: .56)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * .14, size.height * .54), 23, green);
    canvas.drawCircle(Offset(size.width * .23, size.height * .42), 35, green);
    canvas.drawCircle(Offset(size.width * .81, size.height * .54), 24, coral);

    final house = Path()
      ..moveTo(size.width * .62, size.height * .48)
      ..lineTo(size.width * .76, size.height * .23)
      ..lineTo(size.width * .92, size.height * .48)
      ..lineTo(size.width * .89, size.height * .48)
      ..lineTo(size.width * .89, size.height * .75)
      ..lineTo(size.width * .65, size.height * .75)
      ..lineTo(size.width * .65, size.height * .48)
      ..close();
    canvas.drawPath(house, darker);

    final roof = Paint()
      ..color = const Color(0xFF6CC99B).withValues(alpha: .23)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * .59, size.height * .49),
      Offset(size.width * .76, size.height * .22),
      roof,
    );
    canvas.drawLine(
      Offset(size.width * .76, size.height * .22),
      Offset(size.width * .94, size.height * .49),
      roof,
    );

    final trunk = Paint()
      ..color = const Color(0xFF86CDA9).withValues(alpha: .42)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final x in [size.width * .04, size.width * .98]) {
      canvas.drawLine(
        Offset(x, size.height * .83),
        Offset(x, size.height * .45),
        trunk,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x - 8, size.height * .51),
          width: 18,
          height: 34,
        ),
        green,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 9, size.height * .59),
          width: 17,
          height: 32,
        ),
        green,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
