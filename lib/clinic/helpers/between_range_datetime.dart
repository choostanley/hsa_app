import 'package:flutter/material.dart';

extension RangeExtension on DateTimeRange {
  bool isAfterOrEqualTo(DateTime dateTime) {
    // compare with start
    final range = this;
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(range.start);
    return isAtSameMomentAs | dateTime.isAfter(range.start);
  }

  bool isBeforeOrEqualTo(DateTime dateTime) {
    // compare with end
    final range = this;
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(range.end);
    return isAtSameMomentAs | dateTime.isBefore(range.end);
  }

  bool isWithinRange(
    DateTime dateTime,
  ) {
    final range = this;
    final isAfter = range.isAfterOrEqualTo(dateTime);
    final isBefore = range.isAfterOrEqualTo(dateTime);
    return isAfter && isBefore;
  }
}
