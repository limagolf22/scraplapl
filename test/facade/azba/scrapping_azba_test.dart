import 'package:scraplapl/facade/azba/azba_scrapping.dart';
import 'package:test/test.dart';

import '../../test_config.dart';

void main() {
  group('test Azba scrapping 1st phase', () {
    test('test Id generator function', () async {
      String id = generateAuth(
          "Y9Q3Ve72nN3PnTXmEtKnS4sggmdsigRMWH9kCDGHpCHyenFKKGhDq5vgBWZ4",
          "https://bo-prod-sofia-vac.sia-france.fr/api/v1/oacis?page=2&itemsPerPage=800",
          "");
      expect(
          id,
          equals(
              "eyJ0b2tlblVyaSI6Ijg2Mzg3YmQ2ZTg4NjlhNzkwY2RhY2Y1MmFlZThlMWYwNTk5Yzg5OGMyYWUyZTJhYTgyMDJiMTUxYmUxNjhlNzU5MjAxZjlhYWRhMjAwZTY2OWM0OTFkMGU4OTM1YzRjNTkxMWI3MTZmNzU3MzNlMWRhNzhlZjQ4NjQ4MDczZTQwIn0="));
    });

    test('test Id generator function 2', () async {
      String id = generateAuth(
          "Y9Q3Ve72nN3PnTXmEtKnS4sggmdsigRMWH9kCDGHpCHyenFKKGhDq5vgBWZ4",
          "https://bo-prod-sofia-vac.sia-france.fr/api/v2/r_t_b_as?itemsPerPage=200&date=2024-03-21&timeSlots.startTime[before]=2024-04-10T07%3A29%3A00%2B00%3A00&timeSlots.endTime[after]=2024-04-09T00%3A22%3A00%2B00%3A00",
          "");
      expect(
          id,
          equals(
              "eyJ0b2tlblVyaSI6IjgzMWY5Y2JhZmZlNjhjYTZiOGI3OWYwMDU0ZDU3NjBjNzY5ZTMyNDExZDFiMDMyMmQ1YTIwZWNmNTBkZDY4ZDIzY2FmODI1YThiYmRmYmY1OTUyNjIzOWM3MGMwYThmMzE2Y2M4ZGU0N2M3YmQ4Mzg2NDhmNjA3ODhjOWYzYmEwIn0="));
    });

    test('test secret id retriever function', () async {
      String? code = await scrapSecretCode();
      expect(
          code,
          equals(
              "Y9Q3Ve72nN3PnTXmEtKnS4sggmdsigRMWH9kCDGHpCHyenFKKGhDq5vgBWZ4"));
    }, skip: isServerUnavailable);

    test('test get all Azba test content', () async {
      int res = await scrapPdfAllAzba("LFXX", "LFXY");
      expect(res, equals(0));
    }, skip: isServerUnavailable);
  });
}
