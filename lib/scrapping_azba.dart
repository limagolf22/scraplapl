import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:requests/requests.dart';
import 'package:scraplapl/tools.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

Future<int> getPdfAzba(String date, String heure) async {
  var loggerAzba = Logger();

  loggerAzba.i("Request for Azba done at " + date + "," + heure);

  RegExp exp = RegExp(r'share_secret:"([^"]+)"');

  http.Response res1 = await http.get(Uri.parse(
      'https://azba.sia-france.fr/main-es2015.69fe3091c43549df19b9.js'));
  String? secretCode = getSecretCode(res1.body);
  if (secretCode == null) {
    loggerAzba.w("Failed to get Azba secret code");
    return 1;
  }
  loggerAzba.d("secret code found : " + secretCode);

  String formatedDate = date.replaceAll('/', '-');
  //String data =
  //    '?itemsPerPage=200&date=$formatedDate&timeSlots.startTime[before]=${formatedDate}T$heure:00+00:00&timeSlots.endTime[after]=${formatedDate}T$heure:30+00:00';
  String data =
      'itemsPerPage=200&date=2024-03-21&timeSlots.startTime[before]=2024-04-10T07%3A29%3A00%2B00%3A00&timeSlots.endTime[after]=2024-04-09T00%3A22%3A00%2B00%3A00';

  String urlStr =
      'https://bo-prod-sofia-vac.sia-france.fr/api/v2/r_t_b_as?' + data;

  String auth = generateAuth(
      secretCode,
      "https://bo-prod-sofia-vac.sia-france.fr/api/v2/r_t_b_as?itemsPerPage=200&date=2024-03-21&timeSlots.startTime%5Bbefore%5D=2024-04-10T07%3A29%3A00%2B00%3A00&timeSlots.endTime%5Bafter%5D=2024-04-09T00%3A22%3A00%2B00%3A00",
      "");
  loggerAzba.i(auth);
  var headers = {
    'AUTH': auth,
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'fr,fr-FR;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    'Authorization': 'Basic YXBpOkw0YjZQIWQ5K1l1aUc4LU0=',
    'Connection': 'keep-alive',
    'Origin': 'https://azba.sia-france.fr',
    'Referer': 'https://azba.sia-france.fr/',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'same-site',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 Edg/123.0.0.0',
    'sec-ch-ua':
        '"Microsoft Edge";v="123", "Not:A-Brand";v="8", "Chromium";v="123"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
  };

  // var url = Uri.parse(urlStr);
  var url = Uri.parse(
      "https://bo-prod-sofia-vac.sia-france.fr/api/v2/r_t_b_as?itemsPerPage=200&date=2024-03-21&timeSlots.startTime\[before\]=2024-04-10T07%3A29%3A00%2B00%3A00&timeSlots.endTime\[after\]=2024-04-09T00%3A22%3A00%2B00%3A00");

  loggerAzba.i(url);
  var res2 = await http.get(url, headers: headers);

  if (!res2.success) {
    loggerAzba.w("Failed to get Azba content : " + res2.body);
    return 1;
  }
  loggerAzba.w(res2.json());
  return 0;
}

String? getSecretCode(String str) {
  RegExp exp = RegExp(r'share_secret:"([^"]+)"');
  return exp.firstMatch(str)?[1];
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


//curl 'https://bo-prod-sofia-vac.sia-france.fr/api/v2/r_t_b_as?itemsPerPage=200&date=2024-03-21&timeSlots.startTime\[before\]=2024-04-10T07%3A29%3A00%2B00%3A00&timeSlots.endTime\[after\]=2024-04-08T17%3A18%3A00%2B00%3A00' \
//  -H 'AUTH: eyJ0b2tlblVyaSI6ImYxYzE4MjFiNThkYWYxZTczODM0NmMxZDJlZjA2Yjk3MzZjMjc0YjQwZmM3OGQ1OWUwMmNhNDNjMzA4NjAyZDIwMjNlMGRlNzdmYjI0MzFhMjM3YjUxNTk1NTY2ZmEzMWExNjRkZTJjM2RkOGUyYTQyODEyNDU4NWYyZGQ2OTJmIn0=' \
//  -H 'Accept: application/json, text/plain, */*' \
//  -H 'Accept-Language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' \
//  -H 'Authorization: Basic YXBpOkw0YjZQIWQ5K1l1aUc4LU0=' \
//  -H 'Connection: keep-alive' \
//  -H 'Origin: https://azba.sia-france.fr' \
//  -H 'Referer: https://azba.sia-france.fr/' \
//  -H 'Sec-Fetch-Dest: empty' \
//  -H 'Sec-Fetch-Mode: cors' \
//  -H 'Sec-Fetch-Site: same-site' \
//  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36' \
//  -H 'sec-ch-ua: "Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"' \
//  -H 'sec-ch-ua-mobile: ?0' \
//  -H 'sec-ch-ua-platform: "Windows"'