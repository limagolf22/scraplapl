import 'package:scraplapl/main.dart';
import 'package:scraplapl/facade/notam/notam_scrapping.dart';
import 'package:test/test.dart';

void main() {
  group('test Notam Sofia scrapping 1st phase', () {
    test('test Notam function', () async {
      var date = DateTime.now().toUtc().add(const Duration(minutes: 5));
      int value = await getPdfNotamSofia(
          ["LFBO", "LFDG", "LFMT", "LFQQ"],
          "${date.year}/${add0(date.month)}/${add0(date.day)}",
          "${add0(date.hour)}:${add0(date.minute)}");
      expect(value, equals(0));
    });
  });
}
