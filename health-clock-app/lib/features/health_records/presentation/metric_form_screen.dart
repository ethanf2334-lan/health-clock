import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/metric_record.dart';
import '../../members/presentation/member_picker_field.dart';
import '../../members/providers/current_member_provider.dart';
import '../providers/metric_provider.dart';

class _MetricDef {
  final String type;
  final String label;
  final String unit;
  final bool hasExtra;
  const _MetricDef(this.type, this.label, this.unit, {this.hasExtra = false});
}

const _defs = [
  _MetricDef('blood_pressure', '血压', 'mmHg', hasExtra: true),
  _MetricDef('blood_sugar', '血糖', 'mmol/L'),
  _MetricDef('weight', '体重', 'kg'),
  _MetricDef('height', '身高', 'cm'),
  _MetricDef('heart_rate', '心率', 'bpm'),
  _MetricDef('temperature', '体温', '℃'),
  _MetricDef('blood_oxygen', '血氧', '%'),
];

class MetricFormScreen extends ConsumerStatefulWidget {
  const MetricFormScreen({super.key});

  @override
  ConsumerState<MetricFormScreen> createState() => _MetricFormScreenState();
}

class _MetricFormScreenState extends ConsumerState<MetricFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'blood_pressure';
  String? _memberId;
  final _valueController = TextEditingController();
  final _extraController = TextEditingController(); // 舒张压
  final _noteController = TextEditingController();
  DateTime _recordedAt = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _memberId = ref.read(currentMemberIdProvider));
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    _extraController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  _MetricDef get _def => _defs.firstWhere((d) => d.type == _type);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('记录健康指标')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            MemberPickerField(
              value: _memberId,
              onChanged: (v) => setState(() => _memberId = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: '指标'),
              items: _defs
                  .map(
                    (d) =>
                        DropdownMenuItem(value: d.type, child: Text(d.label)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: _def.hasExtra ? '收缩压（高压）' : '数值',
                suffixText: _def.unit,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入数值';
                if (double.tryParse(v) == null) return '请输入有效数字';
                return null;
              },
            ),
            if (_def.hasExtra) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _extraController,
                decoration: InputDecoration(
                  labelText: '舒张压（低压）',
                  suffixText: _def.unit,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return '请输入舒张压';
                  if (double.tryParse(v) == null) return '请输入有效数字';
                  return null;
                },
              ),
            ],
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('记录时间'),
              subtitle:
                  Text(DateFormat('yyyy-MM-dd HH:mm').format(_recordedAt)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: '备注（可选）'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d == null) return;
    if (!mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_recordedAt),
    );
    if (t == null) return;
    setState(() {
      _recordedAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  Future<void> _save() async {
    if (_memberId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请选择成员')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      Map<String, dynamic>? extra;
      if (_def.hasExtra) {
        extra = {
          'diastolic': double.parse(_extraController.text),
        };
      }
      await ref.read(metricListProvider.notifier).add(
            MetricRecordCreate(
              memberId: _memberId!,
              metricType: _type,
              value: double.parse(_valueController.text),
              valueExtra: extra,
              unit: _def.unit,
              recordedAt: _recordedAt,
              note: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已保存')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('保存失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
