import 'package:save_ahead/shared/enum/duration_type.dart';

extension DateTimeExtension on DateTime {

  DateTime addWRT(DurationType durationType) {
    switch (durationType) {
      case DurationType.twentyEightDays:
        return this.add(const Duration(days: 28));
      case DurationType.thirtyDays:
        return this.add(const Duration(days: 30));
      case DurationType.ninetyDays:
        return this.add(const Duration(days: 90));
      case DurationType.oneHundredEightyDays:
        return this.add(const Duration(days: 180));
      case DurationType.threeHundredSixtyFiveDays:
        return this.add(const Duration(days: 365));
      case DurationType.oneMonth:
        return _addMonths(this, 1);
      case DurationType.threeMonths:
        return _addMonths(this, 3);
      case DurationType.sixMonths:
        return _addMonths(this, 6);
      case DurationType.oneYear:
        return _addYears(this, 1);
    }
  }

  DateTime _addMonths(DateTime date, int months) {
    int year = date.year;
    int month = date.month + months;

    year += (month - 1) ~/ 12;
    month = ((month - 1) % 12) + 1;

    int day = date.day;
    int lastDay = _daysInMonth(year, month);

    if (day > lastDay) {
      day = lastDay;
    }

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  DateTime _addYears(DateTime date, int years) {
    int year = date.year + years;

    int day = date.day;
    int lastDay = _daysInMonth(year, date.month);

    if (day > lastDay) {
      day = lastDay;
    }

    return DateTime(
      year,
      date.month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}