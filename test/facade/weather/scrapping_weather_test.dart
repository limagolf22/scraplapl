import 'package:scraplapl/facade/weather/weather_scrapping.dart';
import 'package:test/test.dart';

import '../../test_config.dart';

void main() {
  group('test Weather Sofia scrapping 1st phase', () {
    test('test Weather function', () async {
      var date = DateTime.now().toUtc().add(const Duration(minutes: 5));
      int value = await getPdfWeatherSofia("LFBO", "LFDG", date);
      expect(value, equals(0));
    }, skip: isServerUnavailable);
  });
}
