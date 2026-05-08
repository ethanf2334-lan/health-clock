import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_styles.dart';
import '../../../../shared/models/metric_record.dart';
import '../../../../shared/widgets/app_cupertino_pickers.dart';
import '../../../health_records/data/metric_repository.dart';
import '../../../health_records/providers/metric_provider.dart';
import '../../../members/presentation/widgets/member_avatar.dart';
import '../../../members/providers/current_member_provider.dart';
import '../../../members/providers/member_provider.dart';

final _metricRecentRecordsProvider = FutureProvider.autoDispose
    .family<List<MetricRecord>, _MetricRecentQuery>((ref, query) async {
  if (query.memberId == null || query.memberId!.isEmpty) {
    return const <MetricRecord>[];
  }
  final records = await ref.read(metricRepositoryProvider).listMetrics(
        memberId: query.memberId,
        metricType: query.metricType,
      );
  records.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  return records.take(3).toList();
});

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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppStyles.spacingM,
            AppStyles.spacingS,
            AppStyles.spacingM,
            AppStyles.spacingM + MediaQuery.of(context).padding.bottom * 0.18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: AppStyles.spacingXs,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB8C0C3),
                    borderRadius: BorderRadius.circular(AppStyles.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.spacingS),
              _buildHeader(),
              const SizedBox(height: AppStyles.spacingS),
              _buildMetricTabs(),
              const SizedBox(height: AppStyles.spacingS),
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
                          style: AppStyles.subhead.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      MemberAvatar(
                        name: memberName,
                        relation: memberRelation,
                        size: 28,
                      ),
                      const SizedBox(width: AppStyles.spacingS),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.spacingS),
              ..._buildValueFields(),
              const SizedBox(height: AppStyles.spacingS),
              _buildDateTimeRows(),
              const SizedBox(height: AppStyles.spacingS),
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
              const SizedBox(height: AppStyles.spacingS),
              _buildRecentCard(),
              const SizedBox(height: AppStyles.spacingS),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '记录健康指标',
                style: AppStyles.headline.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppStyles.spacingXs),
              Text(
                '快速记录并持续观察健康变化',
                style: AppStyles.footnote.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppStyles.spacingS),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const CircleBorder(),
            child: Container(
              width: AppStyles.minTouchTarget,
              height: AppStyles.minTouchTarget,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightOutline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, AppStyles.spacingXs),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTabs() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _metrics.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppStyles.spacingS),
        itemBuilder: (context, index) {
          final metric = _metrics[index];
          return _MetricTab(
            metric: metric,
            selected: metric.type == _metricType,
            onTap: () => setState(() => _metricType = metric.type),
          );
        },
      ),
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
        const SizedBox(height: AppStyles.spacingS),
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
        const SizedBox(height: AppStyles.spacingS),
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
                    style: AppStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
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
        const SizedBox(height: AppStyles.spacingS),
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
                    style: AppStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
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
    final memberId = _memberId ?? ref.read(currentMemberIdProvider);
    final recentAsync = ref.watch(
      _metricRecentRecordsProvider(
        _MetricRecentQuery(memberId, _metricType),
      ),
    );

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppStyles.radiusL),
      child: InkWell(
        onTap: () => _openMetricHistory(memberId),
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppStyles.spacingS),
          decoration: BoxDecoration(
            color: AppColors.mintBg.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
            border: Border.all(color: AppColors.lightOutline),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: AppColors.mintDeep,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppStyles.spacingS),
              Expanded(
                child: recentAsync.when(
                  data: (records) => _RecentMetricContent(
                    records: records,
                    metricType: _metricType,
                  ),
                  loading: () => const _RecentMetricLoading(),
                  error: (_, __) => const _RecentMetricEmpty(text: '最近记录加载失败'),
                ),
              ),
              const SizedBox(width: AppStyles.spacingS),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMetricHistory(String? memberId) {
    if (memberId != null && memberId.isNotEmpty) {
      ref.read(currentMemberIdProvider.notifier).state = memberId;
    }
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push('/metrics?type=$_metricType');
  }

  Widget _buildActions() {
    return Column(
      children: [
        InkWell(
          onTap: _saving ? null : _save,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
          child: Container(
            height: 44,
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
              borderRadius: BorderRadius.circular(AppStyles.radiusM),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mintDeep.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, AppStyles.spacingS),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.mintDeep,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppStyles.spacingS),
                Text(
                  _saving ? '保存中...' : '保存记录',
                  style: AppStyles.subhead.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
    final date = await AppCupertinoPickers.date(
      context: context,
      initialDate: _recordedAt,
      minimumDate: DateTime(2020),
      maximumDate: DateTime.now().add(const Duration(days: 1)),
      title: '选择记录日期',
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
    final time = await AppCupertinoPickers.time(
      context: context,
      initialDateTime: _recordedAt,
      title: '选择记录时间',
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppStyles.radiusXl)),
      ),
      builder: (context) => SafeArea(
        child: membersAsync.when(
          data: (members) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              0,
              AppStyles.spacingS,
              0,
              AppStyles.spacingM,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppStyles.spacingM,
                  AppStyles.spacingS,
                  AppStyles.spacingM,
                  AppStyles.spacingM,
                ),
                child: Text(
                  '选择成员',
                  style: AppStyles.headline.copyWith(
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
                    style: AppStyles.subhead.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
            padding: EdgeInsets.all(AppStyles.spacingXxl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(AppStyles.spacingM),
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
      ref.invalidate(
        _metricRecentRecordsProvider(
          _MetricRecentQuery(memberId, _metricType),
        ),
      );
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

class _RecentMetricContent extends StatelessWidget {
  const _RecentMetricContent({
    required this.records,
    required this.metricType,
  });

  final List<MetricRecord> records;
  final String metricType;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) return const _RecentMetricEmpty(text: '暂无最近记录');

    final ordered = [...records]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final values = ordered.map(_displayValue).join('  ←  ');
    final times = ordered.map((r) => _timeText(r.recordedAt)).join('      ');
    final trend = ordered.length >= 2 ? '，${_trendText(ordered)}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近记录  $values$trend',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.subhead.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppStyles.spacingXs),
        Text(
          times,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.footnote.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  String _displayValue(MetricRecord record) {
    if (record.metricType == 'blood_pressure' && record.valueExtra != null) {
      final diastolic = record.valueExtra!['diastolic'];
      if (diastolic != null) {
        return '${_cleanNum(record.value)}/${_cleanNum(diastolic)}';
      }
    }
    return _cleanNum(record.value);
  }

  String _trendText(List<MetricRecord> ordered) {
    final latest = ordered.first.value;
    final earliest = ordered.last.value;
    final diff = latest - earliest;
    final threshold = _trendThreshold(metricType);
    if (diff.abs() <= threshold) return '趋势平稳';
    return diff > 0 ? '趋势上升' : '趋势下降';
  }

  double _trendThreshold(String type) {
    switch (type) {
      case 'blood_pressure':
        return 5;
      case 'blood_sugar':
        return 0.5;
      case 'weight':
        return 0.5;
      case 'heart_rate':
        return 5;
      case 'temperature':
        return 0.3;
      case 'blood_oxygen':
        return 1;
      default:
        return 0.5;
    }
  }

  String _timeText(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day = DateTime(time.year, time.month, time.day);
    final clock = DateFormat('HH:mm').format(time);
    if (day == today) return '今天 $clock';
    if (day == yesterday) return '昨天 $clock';
    return DateFormat('M/d HH:mm').format(time);
  }

  String _cleanNum(Object value) {
    final number = value is num ? value.toDouble() : double.tryParse('$value');
    if (number == null) return '$value';
    if (number % 1 == 0) return number.toInt().toString();
    return number.toStringAsFixed(1);
  }
}

class _RecentMetricLoading extends StatelessWidget {
  const _RecentMetricLoading();

  @override
  Widget build(BuildContext context) {
    return Text(
      '正在读取最近记录...',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppStyles.subhead.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _RecentMetricEmpty extends StatelessWidget {
  const _RecentMetricEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppStyles.subhead.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _MetricRecentQuery {
  const _MetricRecentQuery(this.memberId, this.metricType);

  final String? memberId;
  final String metricType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MetricRecentQuery &&
          other.memberId == memberId &&
          other.metricType == metricType;

  @override
  int get hashCode => Object.hash(memberId, metricType);
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
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: SizedBox(
        width: 66,
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.mintBg.withValues(alpha: 0.55)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
            border: Border.all(
              color: selected
                  ? AppColors.mintDeep.withValues(alpha: 0.35)
                  : AppColors.lightOutline,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 16,
                offset: const Offset(0, AppStyles.spacingXs),
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
                child: Icon(metric.icon, color: metric.color, size: 22),
              ),
              const SizedBox(height: 3),
              Text(
                metric.label,
                style: AppStyles.caption1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
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
          width: 136,
          child: Row(
            children: [
              if (dot)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.mintDeep,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Icon(
                  icon ?? Icons.circle,
                  color: AppColors.mintDeep,
                  size: 16,
                ),
              const SizedBox(width: AppStyles.spacingS),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.subhead.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppStyles.spacingS),
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
      borderRadius: BorderRadius.circular(AppStyles.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingS),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppStyles.radiusM),
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
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusM),
        border: Border.all(color: AppColors.lightOutline),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: AppStyles.subhead.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          filled: false,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(
            AppStyles.spacingS,
            AppStyles.spacingS,
            AppStyles.spacingS,
            AppStyles.spacingS,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
