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
}

AzbaZone parseAzbaZone(dynamic json) {
  List coordinates = json["coordinates"];
  List periods = json["days"];
  return AzbaZone(
      json["name"],
      json["initialCodeType"],
      json["valDistVerUpper"],
      json["valDistVerLower"],
      json["uomDistVerUpper"],
      json["uomDistVerLower"],
      coordinates.map(parseLatLng).toList(),
      periods.map(parseDateTimePeriod).toList(),
      json["txtRmk"]);
}

LatLng parseLatLng(dynamic json) {
  String lat = json["latitude"];

  double latDec = double.parse(lat.substring(0, 2)) +
      double.parse(lat.substring(2, 4)) / 60 +
      double.parse(lat.substring(4, 6) + '.' + lat.substring(7, 9)) / 3600;
  latDec *= lat.contains('N') ? 1 : -1;

  String lon = json["longitude"];

  double lonDec = double.parse(lon.substring(0, 3)) +
      double.parse(lon.substring(3, 5)) / 60 +
      double.parse(lon.substring(5, 7) + '.' + lon.substring(8, 10)) / 3600;
  lonDec *= lon.contains('E') ? 1 : -1;
  return LatLng(latDec, lonDec);
}

DateTimeRange parseDateTimePeriod(dynamic json) {
  DateTime start = DateTime.parse(json["startDate"]);
  DateTime end = DateTime.parse(json["endDate"]);

  return DateTimeRange(start: start, end: end);
}

class Pair<T> {
  T left;
  T right;
  Pair(this.left, this.right);
}
