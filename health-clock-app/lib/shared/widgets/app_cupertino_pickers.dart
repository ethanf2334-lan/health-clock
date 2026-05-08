import 'package:flutter/cupertino.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_styles.dart';

class AppCupertinoPickers {
  const AppCupertinoPickers._();

  static Future<DateTime?> date({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime minimumDate,
    required DateTime maximumDate,
    String title = '选择日期',
  }) {
    return _show(
      context: context,
      title: title,
      initialDate: _clamp(initialDate, minimumDate, maximumDate),
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      mode: CupertinoDatePickerMode.date,
    );
  }

  static Future<DateTime?> time({
    required BuildContext context,
    required DateTime initialDateTime,
    String title = '选择时间',
  }) {
    return _show(
      context: context,
      title: title,
      initialDate: initialDateTime,
      mode: CupertinoDatePickerMode.time,
    );
  }

  static Future<DateTime?> dateTime({
    required BuildContext context,
    required DateTime initialDateTime,
    required DateTime minimumDate,
    required DateTime maximumDate,
    String title = '选择日期与时间',
  }) {
    return _show(
      context: context,
      title: title,
      initialDate: _clamp(initialDateTime, minimumDate, maximumDate),
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      mode: CupertinoDatePickerMode.dateAndTime,
    );
  }

  static Future<DateTime?> _show({
    required BuildContext context,
    required String title,
    required DateTime initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    required CupertinoDatePickerMode mode,
  }) async {
    final minuteInterval = mode == CupertinoDatePickerMode.date ? 1 : 5;
    final alignedInitialDate = _alignToMinuteInterval(
      initialDate,
      minuteInterval,
    );
    var selected = alignedInitialDate;
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) {
        return CupertinoTheme(
          data: const CupertinoThemeData(
            brightness: Brightness.light,
            primaryColor: AppColors.mintDeep,
            textTheme: CupertinoTextThemeData(
              dateTimePickerTextStyle: TextStyle(
                fontSize: 21,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          child: Container(
            height: 336,
            decoration: const BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppStyles.radiusXl),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  _PickerToolbar(title: title),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: mode,
                      initialDateTime: alignedInitialDate,
                      minimumDate: minimumDate,
                      maximumDate: maximumDate,
                      minuteInterval: minuteInterval,
                      use24hFormat: true,
                      onDateTimeChanged: (value) => selected = value,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return confirmed == true ? selected : null;
  }

  static DateTime _clamp(
    DateTime value,
    DateTime minimumDate,
    DateTime maximumDate,
  ) {
    if (value.isBefore(minimumDate)) return minimumDate;
    if (value.isAfter(maximumDate)) return maximumDate;
    return value;
  }

  static DateTime _alignToMinuteInterval(DateTime value, int interval) {
    if (interval <= 1 || value.minute % interval == 0) return value;
    final roundedMinute = ((value.minute / interval).round() * interval);
    final base = DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
    );
    return base.add(Duration(minutes: roundedMinute));
  }
}

class _PickerToolbar extends StatelessWidget {
  const _PickerToolbar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingS),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x1A000000), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingS),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              '取消',
              style: AppStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.headline.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.spacingS),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              '完成',
              style: AppStyles.body.copyWith(
                color: AppColors.mintDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
