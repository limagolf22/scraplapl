import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:scraplapl/kernel/azba/azba_zone.dart';

List<AzbaZone> parseAllAzbaZone(dynamic json) {
  List azbaList = json["hydra:member"];
  return azbaList.map(parseAzbaZone).toList();
}

AzbaZone parseAzbaZone(dynamic json) {
  List coordinates = json["coordinates"];
  List periods = json["timeSlots"];
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
      double.parse(lat.substring(4, 6) +
              '.' +
              (lat.contains('.') ? lat.substring(7, 9) : "0")) /
          3600;
  latDec *= lat.contains('N') ? 1 : -1;

  String lon = json["longitude"];

  double lonDec = double.parse(lon.substring(0, 3)) +
      double.parse(lon.substring(3, 5)) / 60 +
      double.parse(lon.substring(5, 7) +
              '.' +
              (lon.contains('.') ? lon.substring(8, 10) : "0")) /
          3600;
  lonDec *= lon.contains('E') ? 1 : -1;
  return LatLng(latDec, lonDec);
}

DateTimeRange parseDateTimePeriod(dynamic json) {
  DateTime start = DateTime.parse(json["startTime"]);
  DateTime end = DateTime.parse(json["endTime"]);

  return DateTimeRange(start: start, end: end);
}
