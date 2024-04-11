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
    return this.periods.any((period) =>
        period.start.isBefore(dateTime) && period.end.isAfter(dateTime));
  }
}
