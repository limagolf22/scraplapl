import 'package:logger/logger.dart';
import 'package:requests/requests.dart';
import 'package:http/http.dart' as http;
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/main.dart';

var loggerWeather = Logger();

const crossDistance = 45;
const flightLevel = 100;

Future<int> getPdfWeatherSofia(String dep, String arr, DateTime date) async {
  loggerWeather.i("Request for Notam done at $date for airports $dep to $arr");

  http.Response res1 = await http.get(Uri.parse(
      'https://sofia-briefing.aviation-civile.gouv.fr/sofia/pages/homepage.html'));
  String? jsId = res1.headers['set-cookie']?.split(';')[0];
  loggerWeather.d("JS id found : ${jsId!}");

  var headers = {
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
    'Connection': 'keep-alive',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'Cookie': jsId,
    'Origin': 'https://sofia-briefing.aviation-civile.gouv.fr',
    'Referer':
        'https://sofia-briefing.aviation-civile.gouv.fr/sofia/pages/prepavol.html',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'same-origin',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
    'X-Requested-With': 'XMLHttpRequest',
    'sec-ch-ua':
        '"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
  };
  var data =
      // ':operation=postMeteoRoute&adep=$dep&ades=$arr&date=2024-06-08T17:55:43Z&width=45&zone=FRANCE&level=100&waypoints=false&isFromSofia=true&operation=postMeteoRoute&target=#aside-target&href=/sofia/pages/meteoroute.html&typeVol=N&departure_date=08-06-2024&departure_time=1755&lang=fr&routeVal=false';
      ':operation=postMeteoRoute&adep=$dep&ades=$arr&date=${date.toIso8601String()}&width=$crossDistance&zone=FRANCE&level=$flightLevel&waypoints=false&isFromSofia=true&operation=postMeteoRoute&target=#aside-target&href=/sofia/pages/meteoroute.html&typeVol=N&departure_date=${date.toIso8601String().split('T')[0]}&departure_time=${add0(date.toUtc().hour)}${add0(date.toUtc().minute)}&lang=fr&routeVal=false';

  var url2 = Uri.parse('https://sofia-briefing.aviation-civile.gouv.fr/sofia');
  var res2 = await http.post(url2, headers: headers, body: data);

  if (res2.hasError) {
    loggerWeather.w("Failed to setup Weather arguments");
    return 1;
  }

  var headersPdf = {
    'Accept': '*/*',
    'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
    'Connection': 'keep-alive',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'Cookie': jsId,
    'Origin': 'https://sofia-briefing.aviation-civile.gouv.fr',
    'Referer':
        'https://sofia-briefing.aviation-civile.gouv.fr/sofia/pages/meteoroute.html',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'same-origin',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36',
    'X-Requested-With': 'XMLHttpRequest',
    'sec-ch-ua':
        '"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
  };

  var dataPdf =
      ':operation=MeteoRoutePdf&validFrom=${date.toIso8601String()}&uuid=8451867c-685f-4a1e-8985-210a232ab544&isFromSofia=true&isFlightRecord=false';

  var urlPdf = Uri.parse(
      'https://sofia-briefing.aviation-civile.gouv.fr/content/sofia/MeteoRoutePdf');
  var resPdf = await http.post(urlPdf, headers: headersPdf, body: dataPdf);

  if (resPdf.success) {
    pdfDownloads['Weather'] = resPdf.bodyBytes;
    loggerWeather.i("Weather Sofia Pdf bytes downloaded");
    return 0;
  } else {
    loggerWeather.w("Failed to download Weather Sofia");
    return 1;
  }
}
