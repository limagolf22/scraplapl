import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:requests/requests.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:scraplapl/ui/azba/azba_map.dart';
import 'package:scraplapl/facade/azba/azba_parsing.dart';

Future<int> getPdfActiveAzba(DateTime date) async {
  var loggerAzba = Logger();

  loggerAzba.i("Request for Azba done at " + date.toString());

  String? secretCode = await scrapSecretCode();
  if (secretCode == null) {
    loggerAzba.w("Failed to get Azba secret code");
    return 1;
  }
  loggerAzba.d("secret code found : " + secretCode);

  String formatedDateBefore =
      date.subtract(const Duration(days: 0)).toIso8601String().split("T")[0];
  String formatedDate =
      date.add(const Duration(days: 2)).toIso8601String().split("T")[0];
  String formatedDateLastMonth =
      "2024-03-21"; //date.subtract(const Duration(days: 30)).toIso8601String().split("T")[0];

  String data =
      '?itemsPerPage=200&date=$formatedDateLastMonth&timeSlots.startTime%5Bbefore%5D=${formatedDate}T00%3A01%3A30%2B00%3A00&timeSlots.endTime%5Bafter%5D=${formatedDateBefore}T00%3A22%3A00%2B00%3A00';

  String urlStr =
      'https://bo-prod-sofia-vac.sia-france.fr/api/v2/r_t_b_as' + data;

  String auth = generateAuth(secretCode, urlStr, "");
  var headers = {
    'AUTH': auth,
    'Accept': 'application/json, text/plain, */*',
    'Connection': 'keep-alive',
    'Origin': 'https://azba.sia-france.fr',
    'Referer': 'https://azba.sia-france.fr/',
  };

  var url = Uri.parse(urlStr);

  var res2 = await http.get(url, headers: headers);

  if (!res2.success) {
    loggerAzba.w("Failed to get Azba content : " + res2.body);
    return 1;
  }
  var resultJson = res2.json();
  if (resultJson["@id"] == null) {
    //TODO: add validation of Azba datas
    loggerAzba.w('content of Azba has the wrong format');
    return 1;
  }

  changeAzbaZone(parseAllAzbaZone(resultJson));
  //loggerAzba.d(resultJson);
  loggerAzba.d(azbaZones);
  return 0;
}

Future<int> getPdfAllAzba(DateTime date) async {
  var loggerAzba = Logger();

  loggerAzba.i("Request for Azba done at " + date.toString());

  String? secretCode = await scrapSecretCode();
  if (secretCode == null) {
    loggerAzba.w("Failed to get Azba secret code");
    return 1;
  }
  loggerAzba.d("secret code found : " + secretCode);

  String? formatedDateLastMonth = await scrapDate(secretCode);
  if (formatedDateLastMonth == null) {
    loggerAzba.w("Failed to get Azba validity date");
    return 1;
  }

  String data = "?date=$formatedDateLastMonth&page=1&itemsPerPage=800";

  String urlStr =
      'https://bo-prod-sofia-vac.sia-france.fr/api/v2/r_t_b_as' + data;

  String auth = generateAuth(secretCode, urlStr, "");
  var headers = {
    'AUTH': auth,
    'Accept': 'application/json, text/plain, */*',
    'Connection': 'keep-alive',
    'Origin': 'https://azba.sia-france.fr',
    'Referer': 'https://azba.sia-france.fr/',
  };

  var url = Uri.parse(urlStr);

  var res = await http.get(url, headers: headers);

  if (!res.success) {
    loggerAzba.w("Failed to get Azba content : " + res.body);
    return 1;
  }
  var resultJson = res.json();
  if (resultJson["@id"] == null) {
    //TODO: add validation of Azba datas
    loggerAzba.w('content of Azba has the wrong format');
    return 1;
  }

  changeAzbaZone(parseAllAzbaZone(resultJson));
  loggerAzba.d(azbaZones);

  return 0;
}

Future<String?> scrapDate(String secretCode) async {
  String urlStr =
      'https://bo-prod-sofia-vac.sia-france.fr/api/v2/custom/currentDate';

  String auth = generateAuth(secretCode, urlStr, "");
  var headers = {
    'AUTH': auth,
    'Accept': 'application/json, text/plain, */*',
    'Connection': 'keep-alive',
    'Origin': 'https://azba.sia-france.fr',
    'Referer': 'https://azba.sia-france.fr/',
  };
  var url = Uri.parse(urlStr);

  var res = await http.get(url, headers: headers);
  return res.success ? res.json()['rtba'] : null;
}

Future<String?> scrapSecretCode() async {
  http.Response resJs = await http.get(Uri.parse(
      'https://azba.sia-france.fr/main-es2015.69fe3091c43549df19b9.js'));
  if (resJs.success) {
    RegExp exp = RegExp(r'share_secret:"([^"]+)"');
    return exp.firstMatch(resJs.body)?[1];
  }
  return null;
}

String generateAuth(String share_secret, String urlWithParams, String body) {
  String n = share_secret + "/api/" + urlWithParams.split("/api/")[1];
  var tokenUri = toSha512(n);
  if (body == "") {
    var jsonStr = '{"tokenUri":"' + tokenUri + '"}';
    return base64.encode(utf8.encode(jsonStr));
  } else {
    var jsonStr = '{"tokenUri":"' +
        tokenUri +
        '","tokenParams":"' +
        toSha512(body) +
        '"}';
    return base64.encode(utf8.encode(jsonStr));
  }
}

String toSha512(String str) {
  return sha512.convert(utf8.encode(str)).toString();
}
