import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:requests/requests.dart';
import 'package:scraplapl/kernel/store/stores.dart';

Future<int> getPdfNotamSofia(
    List<String> airports, String date, String heure) async {
  var loggerNotam = Logger();

  loggerNotam
      .i("Request for Notam done at $date,${heure}for airports $airports");

  http.Response res1 = await http.get(Uri.parse(
      'https://sofia-briefing.aviation-civile.gouv.fr/sofia/pages/homepage.html'));
  String? jsId = res1.headers['set-cookie']?.split(';')[0];
  loggerNotam.d("JS id found : ${jsId!}");
  var headers = {
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'Cookie': jsId,
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Referer':
        'https://sofia-briefing.aviation-civile.gouv.fr/sofia/pages/notamsearchaero.html'
  };

  String data =
      ':operation=postAeroPibRequest&valid_from=${date.replaceAll('/', '-')}T$heure:07Z&duration=1200&traffic=VI&${airports.map((a) => "aero[]=$a&").join()}uuid=fb6d50ce-db63-4e64-bb12-5f21edc0a57d&isFromSofia=true&operation=postAeroPibRequest&target=#aside-target&href=/sofia/pages/notamaero.html&typeVol=NA&departure_date=${date.split('/').reversed.join('-')}&departure_time=${heure.replaceAll(':', '')}&lang=fr&routeVal=false';

  var url = Uri.parse('https://sofia-briefing.aviation-civile.gouv.fr/sofia');
  var res2 = await http.post(url, headers: headers, body: data);

  RegExp reg1 = RegExp(r'(?<="id\\":\\")\d+(?=\\")');

  Iterable<RegExpMatch> allMatches = reg1.allMatches(res2.body);

  List<String> idList = allMatches.map((e) => e.group(0)!).toList();

  if (idList.isEmpty) {
    loggerNotam.w("Failed to get Notam Ids"); //TODO: manage case where no notams are available
    return 1;
  }

  var headersPdf = {
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'Accept': '*/*',
    'Referer':
        'https://sofia-briefing.aviation-civile.gouv.fr/sofia/pages/notamaero.html',
    'Cookie': jsId
  };

  var dataPdf =
      '${idList.map((id) => "selected[]=$id&").join()}${airports.map((a) => "aerodromes[]=$a&").join()}title=prepa_notamaero&duration=1200&validFrom=${date.replaceAll('/', '-')}T$heure:07Z&uuid=fb6d50ce-db63-4e64-bb12-5f21edc0a57d&isFromSofia=true';

  var urlPdf = Uri.parse(
      'https://sofia-briefing.aviation-civile.gouv.fr/content/sofia/AeroPibPdf');
  http.Response resPdf =
      await http.post(urlPdf, headers: headersPdf, body: dataPdf);
  if (resPdf.success) {
    pdfDownloads['Notam'] = resPdf.bodyBytes;
    loggerNotam.i("Notam Sofia Pdf bytes downloaded");
    return 0;
  } else {
    loggerNotam.w("Failed to download Notam Sofia");
    return 1;
  }
}
