import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/metric_record.dart';
import '../../../health_records/providers/metric_provider.dart';
import '../../../members/presentation/widgets/member_avatar.dart';
import '../../../members/providers/current_member_provider.dart';
import '../../../members/providers/member_provider.dart';

class MetricRecordSheet extends ConsumerStatefulWidget {
  const MetricRecordSheet({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  ConsumerState<MetricRecordSheet> createState() => _MetricRecordSheetState();
}

class _MetricRecordSheetState extends ConsumerState<MetricRecordSheet> {
  final _systolicController = TextEditingController(text: '128');
  final _diastolicController = TextEditingController(text: '78');
  final _heartRateController = TextEditingController(text: '72');
  final _noteController = TextEditingController(text: '晨起测量');
  final _singleValueController = TextEditingController(text: '5.8');

  String _metricType = 'blood_pressure';
  String? _memberId;
  DateTime _recordedAt = _initialTime();
  bool _saving = false;

  static DateTime _initialTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 8, 30);
  }

  static const _metrics = [
    _MetricOption(
      'blood_pressure',
      '血压',
      'mmHg',
      Icons.monitor_heart_rounded,
      AppColors.mintDeep,
      AppColors.mintBg,
    ),
    _MetricOption(
      'blood_sugar',
      '血糖',
      'mmol/L',
      Icons.water_drop_rounded,
      AppColors.lavender,
      AppColors.lavenderSoft,
    ),
    _MetricOption(
      'weight',
      '体重',
      'kg',
      Icons.scale_rounded,
      Color(0xFF7384E8),
      Color(0xFFEAEFFF),
    ),
    _MetricOption(
      'heart_rate',
      '心率',
      '次/分',
      Icons.favorite_rounded,
      AppColors.rose,
      AppColors.roseSoft,
    ),
    _MetricOption(
      'temperature',
      '体温',
      '℃',
      Icons.thermostat_rounded,
      AppColors.careBlue,
      AppColors.careBlueSoft,
    ),
    _MetricOption(
      'blood_oxygen',
      '血氧',
      '%',
      Icons.water_drop_outlined,
      Color(0xFF7EC7F2),
      Color(0xFFE7F6FE),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _memberId = ref.read(currentMemberIdProvider));
    });
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _noteController.dispose();
    _singleValueController.dispose();
    super.dispose();
  }

  _MetricOption get _selectedMetric => _metrics.firstWhere(
        (item) => item.type == _metricType,
        orElse: () => _metrics.first,
      );

  @override
  Widget build(BuildContext context) {
    ref.watch(ensureCurrentMemberProvider);
    final membersAsync = ref.watch(memberListProvider);
    final memberName = _memberName(membersAsync);
    final memberRelation = _memberRelation(membersAsync);

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            18 + MediaQuery.of(context).padding.bottom * 0.18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8C0C3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 22),
              _buildMetricTabs(),
              const SizedBox(height: 18),
              _LabeledRow(
                icon: Icons.person_outline_rounded,
                label: '成员',
                child: _InputShell(
                  onTap: _showMemberPicker,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          memberName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      MemberAvatar(
                        name: memberName,
                        relation: memberRelation,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 23,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._buildValueFields(),
              const SizedBox(height: 12),
              _buildDateTimeRows(),
              const SizedBox(height: 12),
              _LabeledRow(
                icon: Icons.notes_rounded,
                label: '备注（选填）',
                child: _TextInputShell(
                  controller: _noteController,
                  hintText: '备注',
                  keyboardType: TextInputType.text,
                  onChanged: (_) => setState(() {}),
                  suffixIcon: null,
                ),
              ),
              const SizedBox(height: 18),
              _buildRecentCard(),
              const SizedBox(height: 20),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '记录健康指标',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '快速记录并持续观察健康变化',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightOutline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTabs() {
    return Row(
      children: [
        for (final metric in _metrics) ...[
          Expanded(
            child: _MetricTab(
              metric: metric,
              selected: metric.type == _metricType,
              onTap: () => setState(() => _metricType = metric.type),
            ),
          ),
          if (metric != _metrics.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  List<Widget> _buildValueFields() {
    if (_metricType == 'blood_pressure') {
      return [
        _LabeledRow(
          dot: true,
          label: '收缩压 (mmHg)',
          child: _TextInputShell(
            controller: _systolicController,
            hintText: '收缩压',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        _LabeledRow(
          dot: true,
          label: '舒张压 (mmHg)',
          child: _TextInputShell(
            controller: _diastolicController,
            hintText: '舒张压',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        _LabeledRow(
          icon: Icons.favorite_border_rounded,
          label: '心率 (次/分)',
          child: _TextInputShell(
            controller: _heartRateController,
            hintText: '心率',
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ];
    }

    return [
      _LabeledRow(
        dot: true,
        label: '${_selectedMetric.label} (${_selectedMetric.unit})',
        child: _TextInputShell(
          controller: _singleValueController,
          hintText: '请输入数值',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
        ),
      ),
    ];
  }

  Widget _buildDateTimeRows() {
    return Column(
      children: [
        _LabeledRow(
          icon: Icons.calendar_today_outlined,
          label: '日期',
          child: _InputShell(
            onTap: _pickDate,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('yyyy/MM/dd').format(_recordedAt),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 21,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _LabeledRow(
          icon: Icons.access_time_rounded,
          label: '时间',
          child: _InputShell(
            onTap: _pickTime,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('HH:mm').format(_recordedAt),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 22,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.mintBg.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.show_chart_rounded,
              color: AppColors.mintDeep,
              size: 33,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最近记录  126/76  →  132/82  →  128/78，趋势平稳',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '07/10 08:15        07/11 08:20        今天 08:30',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 27,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        InkWell(
          onTap: _saving ? null : _save,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF34C58A),
                  Color(0xFF16995C),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mintDeep.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.mintDeep,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _saving ? '保存中...' : '保存记录',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
            context.push('/metrics');
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.lightOutline),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart_rounded,
                  color: AppColors.mintDeep,
                  size: 25,
                ),
                SizedBox(width: 10),
                Text(
                  '查看趋势',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.mintDeep,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null) return;
    setState(() {
      _recordedAt = DateTime(
        date.year,
        date.month,
        date.day,
        _recordedAt.hour,
        _recordedAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_recordedAt),
    );
    if (time == null) return;
    setState(() {
      _recordedAt = DateTime(
        _recordedAt.year,
        _recordedAt.month,
        _recordedAt.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _showMemberPicker() {
    final membersAsync = ref.read(memberListProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: membersAsync.when(
          data: (members) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  '选择成员',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...members.map(
                (member) => ListTile(
                  leading: MemberAvatar(
                    name: member.name,
                    relation: member.relation,
                  ),
                  title: Text(
                    member.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: _memberId == member.id
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.mintDeep,
                        )
                      : null,
                  onTap: () {
                    setState(() => _memberId = member.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: Text('加载失败：$e'),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final memberId = _memberId ?? ref.read(currentMemberIdProvider);
    if (memberId == null || memberId.isEmpty) {
      _showMessage('请选择成员');
      return;
    }

    final metric = _selectedMetric;
    final valueText = _metricType == 'blood_pressure'
        ? _systolicController.text.trim()
        : _singleValueController.text.trim();
    final value = double.tryParse(valueText);
    if (value == null) {
      _showMessage('请输入有效数值');
      return;
    }

    Map<String, dynamic>? extra;
    if (_metricType == 'blood_pressure') {
      final diastolic = double.tryParse(_diastolicController.text.trim());
      if (diastolic == null) {
        _showMessage('请输入有效舒张压');
        return;
      }
      extra = {
        'diastolic': diastolic,
        if (double.tryParse(_heartRateController.text.trim()) != null)
          'heart_rate': double.parse(_heartRateController.text.trim()),
      };
    }

    setState(() => _saving = true);
    try {
      await ref.read(metricListProvider.notifier).add(
            MetricRecordCreate(
              memberId: memberId,
              metricType: _metricType,
              value: value,
              valueExtra: extra,
              unit: metric.unit,
              recordedAt: _recordedAt,
              note: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
            ),
          );
      if (!mounted) return;
      widget.onSaved?.call();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('指标已保存')),
      );
    } catch (e) {
      if (mounted) _showMessage('保存失败：$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _memberName(AsyncValue membersAsync) {
    return membersAsync.maybeWhen(
      data: (members) {
        for (final member in members) {
          if (member.id == _memberId) return member.name as String;
        }
        return members.isEmpty ? '妈妈' : members.first.name as String;
      },
      orElse: () => '妈妈',
    );
  }

  String? _memberRelation(AsyncValue membersAsync) {
    return membersAsync.maybeWhen(
      data: (members) {
        for (final member in members) {
          if (member.id == _memberId) return member.relation as String?;
        }
        return members.isEmpty ? null : members.first.relation as String?;
      },
      orElse: () => null,
    );
  }
}

class _MetricOption {
  const _MetricOption(
    this.type,
    this.label,
    this.unit,
    this.icon,
    this.color,
    this.bg,
  );

  final String type;
  final String label;
  final String unit;
  final IconData icon;
  final Color color;
  final Color bg;
}

class _MetricTab extends StatelessWidget {
  const _MetricTab({
    required this.metric,
    required this.selected,
    required this.onTap,
  });

  final _MetricOption metric;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.mintBg.withValues(alpha: 0.55)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.mintDeep.withValues(alpha: 0.35)
                : AppColors.lightOutline,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: metric.bg,
                shape: BoxShape.circle,
              ),
              child: Icon(metric.icon, color: metric.color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              metric.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color:
                    selected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledRow extends StatelessWidget {
  const _LabeledRow({
    required this.label,
    required this.child,
    this.icon,
    this.dot = false,
  });

  final String label;
  final Widget child;
  final IconData? icon;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 190,
          child: Row(
            children: [
              if (dot)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.mintDeep,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Icon(
                  icon ?? Icons.circle,
                  color: AppColors.mintDeep,
                  size: 23,
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }
}

class _InputShell extends StatelessWidget {
  const _InputShell({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.lightOutline),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TextInputShell extends StatelessWidget {
  const _TextInputShell({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.onChanged,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          filled: false,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
