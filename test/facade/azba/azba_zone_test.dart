import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:scraplapl/facade/azba/azba_parsing.dart';
import 'package:scraplapl/kernel/azba/azba_zone.dart';
import 'package:test/test.dart';

void main() {
  group('test Azba parsing', () {
    test('test a single Azba parsing', () async {
      var json = {
        "@id": "/api/v2/r_t_b_as/63",
        "@type": "RTBA",
        "date": "2024-03-21",
        "coordinates": [
          {
            "@id": "/api/v1/coordinates/37411",
            "@type": "Coordinate",
            "latitude": "480037.00N",
            "longitude": "0055241.00E",
            "codeType": "GRC",
            "geoLongArc": null,
            "valRadiusArc": null,
            "geoLatArc": null
          },
          {
            "@id": "/api/v1/coordinates/37412",
            "@type": "Coordinate",
            "latitude": "480522.00N",
            "longitude": "0054205.00E",
            "codeType": "GRC",
            "geoLongArc": null,
            "valRadiusArc": null,
            "geoLatArc": null
          }
        ],
        "name": "45 S2",
        "valDistVerUpper": 65,
        "valDistVerLower": 800,
        "uomDistVerUpper": "FL",
        "uomDistVerLower": "FT",
        "codeClass": null,
        "codeType": "RD",
        "codeId": "LFR45S2",
        "initialCodeType": "R",
        "txtRmk":
            "Administrator : CDPGE Athis-Mons.#Avoidance mandatory during activation hours.",
        "codeDistVerUpper": "STD",
        "codeDistVerLower": "HEI",
        "timeSlots": [
          {
            "@id": "/api/v2/time_slots/8044",
            "@type": "TimeSlot",
            "startTime": "2023-12-08T07:29:00+00:00",
            "endTime": "2023-12-12T07:29:00+00:00"
          },
          {
            "@id": "/api/v2/time_slots/8044",
            "@type": "TimeSlot",
            "startTime": "2023-12-20T07:29:00+00:00",
            "endTime": "2023-12-22T07:29:00+00:00"
          }
        ],
        "days": [
          {
            "@id": "/api/v2/days/2166",
            "@type": "Day",
            "startDate": "2024-04-09T07:30:00+00:00",
            "endDate": "2024-04-09T10:00:00+00:00"
          }
        ]
      };
      AzbaZone azbaZone = parseAzbaZone(json);
      expect(
          azbaZone.toString(),
          equals(AzbaZone(
                  "45 S2",
                  "R",
                  65,
                  800,
                  "FL",
                  "FT",
                  [LatLng(48.010278, 5.878056), LatLng(48.089444, 5.701389)],
                  [
                    DateTimeRange(
                        start: DateTime(2023, 12, 8, 8, 29).toUtc(),
                        end: DateTime(2023, 12, 12, 8, 29).toUtc()),
                    DateTimeRange(
                        start: DateTime(2023, 12, 20, 8, 29).toUtc(),
                        end: DateTime(2023, 12, 22, 8, 29).toUtc())
                  ],
                  "Administrator : CDPGE Athis-Mons.#Avoidance mandatory during activation hours.")
              .toString()));
    }, skip: false);
    test('test a get Activation Starts and Ends', () async {
      var az = AzbaZone(
          "45 S2",
          "R",
          65,
          800,
          "FL",
          "FT",
          [LatLng(48.010278, 5.878056), LatLng(48.089444, 5.701389)],
          [
            DateTimeRange(
                start: DateTime(2023, 12, 8), end: DateTime(2023, 12, 12)),
            DateTimeRange(
                start: DateTime(2023, 12, 10), end: DateTime(2023, 12, 14)),
            DateTimeRange(
                start: DateTime(2023, 12, 6), end: DateTime(2023, 12, 8)),
            DateTimeRange(
                start: DateTime(2023, 12, 2), end: DateTime(2023, 12, 3)),
            DateTimeRange(
                start: DateTime(2023, 12, 14), end: DateTime(2023, 12, 15)),
            DateTimeRange(
                start: DateTime(2023, 12, 16), end: DateTime(2023, 12, 20))
          ],
          "Test");
      expect(
          az.getActivationStarts(),
          equals(Set.of({
            DateTime(2023, 12, 2),
            DateTime(2023, 12, 6),
            DateTime(2023, 12, 16)
          })));
      expect(
          az.getActivationEnds(),
          equals(Set.of({
            DateTime(2023, 12, 3),
            DateTime(2023, 12, 15),
            DateTime(2023, 12, 20)
          })));
    });
  });
}
