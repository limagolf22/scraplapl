import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class AzbaZone {
  String name;
  String type;
  int upperLevel;
  int lowerLevel;
  String upperUnit;
  String lowerUnit;
  List<LatLng> coordinates;
  List<DateTimeRange> periods;
  String rmk;

  AzbaZone(this.name, this.type, this.upperLevel, this.lowerLevel,
      this.upperUnit, this.lowerUnit, this.coordinates, this.periods, this.rmk);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AzbaZone &&
        other.name == name &&
        other.type == type &&
        other.upperLevel == upperLevel &&
        other.lowerLevel == lowerLevel &&
        other.upperUnit == upperUnit &&
        other.lowerUnit == lowerUnit &&
        listEquals(other.coordinates, coordinates) &&
        listEquals(other.periods, periods) &&
        other.rmk == rmk;
  }

  @override
  String toString() {
    return 'AzbaZone{name: $name, type: $type, upperLevel: $upperLevel, lowerLevel: $lowerLevel, '
        'upperUnit: $upperUnit, lowerUnit: $lowerUnit, coordinates: $coordinates, '
        'periods: $periods, rmk: $rmk}';
  }

  bool isAzbaActive(DateTime dateTime) {
    return periods.any((p) => isWithinWithoutEnd(dateTime, p));
  }

  Set<DateTime> getActivationStarts() {
    return periods
        .where((p1) => !periods
            .any((p2) => isWithin(p1.start, p2) && p1.start != p2.start))
        .map((p) => p.start)
        .toSet();
  }

  Set<DateTime> getActivationEnds() {
    return periods
        .where((p1) =>
            !periods.any((p2) => isWithin(p1.end, p2) && p1.end != p2.end))
        .map((p) => p.end)
        .toSet();
  }
}

/// test if a moment is within a period : t in [s;e]
bool isWithin(DateTime dateTime, DateTimeRange period) {
  return !period.start.isAfter(dateTime) && !period.end.isBefore(dateTime);
}

/// test if a moment is within a period : t in [s;e[
bool isWithinWithoutEnd(DateTime dateTime, DateTimeRange period) {
  return !period.start.isAfter(dateTime) && period.end.isAfter(dateTime);
}
