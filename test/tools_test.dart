import 'package:scraplapl/tools.dart';
import 'package:test/test.dart';

void main() {
  group('test functions in AppUtil', () {
    test('test isICAO function', () async {
      bool value1 = AppUtil.isICAO("LFBO");
      bool value2 = AppUtil.isICAO("lFBO");
      bool value3 = AppUtil.isICAO("LFBO ");
      expect(value1, equals(true));
      expect(value2, equals(false));
      expect(value3, equals(false));
    });
  });
}
