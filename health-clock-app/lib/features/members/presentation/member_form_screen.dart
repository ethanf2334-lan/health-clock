import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/models/member.dart';
import '../data/member_repository.dart';
import '../providers/current_member_provider.dart';
import '../providers/member_provider.dart';

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
  static const _pageBg = Color(0xFFF6FBF8);

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
      backgroundColor: _pageBg,
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FCFA),
              Color(0xFFF3FAF6),
              Colors.white,
            ],
            stops: [0, .48, 1],
          ),
        ),
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
                  padding: EdgeInsets.fromLTRB(18, 6, 18, 16 + bottomInset),
                  sliver: SliverList.list(
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 14),
                      _buildCurrentMemberCard(),
                      const SizedBox(height: 14),
                      _buildTipCard(),
                      const SizedBox(height: 22),
                      _buildPrimaryButton(),
                      const SizedBox(height: 12),
                      _buildCancelButton(),
                      const SizedBox(height: 26),
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
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.chevron_left_rounded,
                size: 34,
                color: AppColors.textPrimary,
              ),
              style: IconButton.styleFrom(
                minimumSize: const Size(42, 42),
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
                style: const TextStyle(
                  fontSize: 27,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.2,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
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
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 34,
            right: 24,
            bottom: 30,
            child: SizedBox(
              height: 112,
              child: CustomPaint(painter: _FamilyBackdropPainter()),
            ),
          ),
          Positioned(
            top: 34,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 156,
                  height: 156,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .08),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(9),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE8F4FF), Color(0xFFD4ECFF)],
                      ),
                    ),
                    child: const _DefaultPortrait(),
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: 14,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF42B87B),
                      border: Border.all(color: Colors.white, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .12),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: 25,
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
          const _ThinDivider(horizontal: 18),
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
          _notesRow(),
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
      padding: const EdgeInsets.fromLTRB(24, 17, 24, 17),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
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
                fontSize: 18,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 82,
            child: Padding(
              padding: EdgeInsets.only(top: 9),
              child: Text(
                '关系',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 13,
              runSpacing: 13,
              children: [
                for (final item in items)
                  _ChoicePill(
                    label: item.$2,
                    selected: _relation == item.$1,
                    color: item.$1 == 'child'
                        ? const Color(0xFFFF982F)
                        : _greenDeep,
                    onTap: () => setState(() => _relation = item.$1),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '性别',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
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
        padding: const EdgeInsets.fromLTRB(24, 17, 22, 17),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                '出生日期或年龄',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
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
                  fontSize: 17,
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
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notesRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 17, 24, 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 132,
                child: Text(
                  '备注（选填）',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _notesController,
                  textAlign: TextAlign.right,
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 100,
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: '请输入备注信息',
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedBuilder(
              animation: _notesController,
              builder: (context, _) => Text(
                '${_notesController.text.characters.length}/100',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMemberCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 18, 20),
      decoration: _cardDecoration(radius: 18),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '设为当前成员',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  '开启后，将在首页优先展示该成员数据',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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

  Widget _buildTipCard() {
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.fromLTRB(22, 18, 20, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFE8FAF2), Color(0xFFF5FCF8)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_rounded, color: _greenDeep, size: 25),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '温馨提示',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: _greenDeep,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  '每位家庭成员将拥有独立的健康提醒、健康档案和健康指标，我们会为您和家人的健康数据严格保密。',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          _TipIllustration(),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      height: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(31),
          gradient: const LinearGradient(
            colors: [Color(0xFF43C181), Color(0xFF13A85A)],
          ),
          boxShadow: [
            BoxShadow(
              color: _green.withValues(alpha: .22),
              blurRadius: 18,
              offset: const Offset(0, 8),
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
              borderRadius: BorderRadius.circular(31),
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _greenDeep,
          side: BorderSide(color: Colors.black.withValues(alpha: .05)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(29),
          ),
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: .08),
        ),
        child: const Text(
          '取消',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
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
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: '选择出生日期',
      cancelText: '取消',
      confirmText: '确定',
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
        height: 36,
        constraints: const BoxConstraints(minWidth: 78),
        padding: const EdgeInsets.symmetric(horizontal: 18),
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
            fontSize: 16,
            fontWeight: FontWeight.w800,
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
      width: 230,
      height: 46,
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
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color:
                  selected ? const Color(0xFF148956) : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultPortrait extends StatelessWidget {
  const _DefaultPortrait();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 22,
          child: Container(
            width: 76,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(42),
                topRight: Radius.circular(42),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(18),
              ),
            ),
          ),
        ),
        Positioned(
          top: 45,
          child: Container(
            width: 70,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC2A3),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 17,
                  top: 27,
                  child: _FaceDot(),
                ),
                Positioned(
                  right: 17,
                  top: 27,
                  child: _FaceDot(),
                ),
                const Positioned(
                  left: 31,
                  top: 36,
                  child: SizedBox(
                    width: 8,
                    height: 14,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFE89275),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 16,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFFDB745D).withValues(alpha: .85),
                          width: 2,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 31,
          left: 36,
          right: 18,
          child: Container(
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF2F3033),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(28),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -6,
          child: Container(
            width: 104,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFF5DADE9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(44),
                topRight: Radius.circular(44),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FaceDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 11,
      decoration: BoxDecoration(
        color: const Color(0xFF303136),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _TipIllustration extends StatelessWidget {
  const _TipIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 5,
            bottom: 2,
            child: Container(
              width: 54,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFE9FFF3),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFF8CDAB3), width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 27,
                    height: 5,
                    color: const Color(0xFFBBDCCA),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 31,
                    height: 5,
                    color: const Color(0xFFD2E8DC),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    width: 25,
                    height: 5,
                    color: const Color(0xFFD2E8DC),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFF4CC082),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 15,
            child: Icon(
              Icons.eco_rounded,
              color: const Color(0xFF8CDAB3).withValues(alpha: .85),
              size: 28,
            ),
          ),
        ],
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
