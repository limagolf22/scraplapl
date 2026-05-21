import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:scraplapl/facade/azba/azba_pdf.dart';
import 'package:scraplapl/kernel/azba/azba_zone.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:test/test.dart';

void main() {
  group('test Azba PDF generation', () {
    test('test Azba PDF file generation', () async {
      var azbaZone = AzbaZone(
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
          "Administrator : CDPGE Athis-Mons.#Avoidance mandatory during activation hours.");
      azbaZones.add(azbaZone);
      activationsTimes.addAll(azbaZone.getActivationStarts());
      await saveAzbaPdf();

      expect(
          pdfDownloads['Azba'] != null && pdfDownloads['Azba']!.isNotEmpty,
          equals(
              true));
    });
  });
}
