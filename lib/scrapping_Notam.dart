
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:requests/requests.dart';
import 'package:scraplapl/tools.dart';


Future<int> getPdfNotamSofia(List<String> airports, String date, String heure) async {
  http.Response res1 = await http.get(Uri.parse('https://sofia-briefing.aviation-civile.gouv.fr/sofia/pages/homepage.html'));
  String? JSId = res1.headers['set-cookie']?.split(';')[0];

  var headers = {
    'sec-ch-ua': '"Not?A_Brand";v="8", "Chromium";v="108", "Google Chrome";v="108"',
    'sec-ch-ua-mobile': '?0',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'Cookie': JSId!,
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Referer': 'https://sofia-briefing.aviation-civile.gouv.fr/sofia/pages/notamsearchaero.html',
    'X-Requested-With': 'XMLHttpRequest',
    'sec-ch-ua-platform': '"Windows"',
    'Accept-Encoding': 'gzip',
  };

  String data =':operation=postAeroPibRequest&valid_from=${date.replaceAll('/', '-')}T${heure}:07Z&duration=1200&traffic=VI&'+airports.map((a) => "aero[]=$a&").join()+'uuid=fb6d50ce-db63-4e64-bb12-5f21edc0a57d&isFromSofia=true&operation=postAeroPibRequest&target=#aside-target&href=/sofia/pages/notamaero.html&typeVol=NA&departure_date=${date.split('/').reversed.join('-')}&departure_time=${heure.replaceAll(':', '')}&lang=fr&routeVal=false';

  var url = Uri.parse('https://sofia-briefing.aviation-civile.gouv.fr/sofia');
  var res2 = await http.post(url, headers: headers, body: data);

  RegExp reg1 = new RegExp(r'(?<="id\\":\\")\d+(?=\\")');

  Iterable<RegExpMatch> allMatches = reg1.allMatches(res2.body);

  List<String> idList = allMatches.map((e) => e.group(0)!).toList();

  if (idList.length==0){
    print("Failed to get Notam Ids");
    return 1;
  }


  var headersPdf = {
    'sec-ch-ua': '"Not?A_Brand";v="8", "Chromium";v="108", "Google Chrome";v="108"',
    'sec-ch-ua-mobile': '?0',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'Accept': '*/*',
    'Referer': 'https://sofia-briefing.aviation-civile.gouv.fr/sofia/pages/notamaero.html',
    'X-Requested-With': 'XMLHttpRequest',
    'sec-ch-ua-platform': '"Windows"',
    'Accept-Encoding': 'gzip',
    'Cookie':JSId
  };

  var dataPdf = idList.map((id) => "selected[]=$id&").join() + airports.map((a) => "aerodromes[]=$a&").join()+'title=prepa_notamaero&duration=1200&validFrom=${date.replaceAll('/', '-')}T${heure}:07Z&uuid=fb6d50ce-db63-4e64-bb12-5f21edc0a57d&isFromSofia=true';

  var urlPdf = Uri.parse('https://sofia-briefing.aviation-civile.gouv.fr/content/sofia/AeroPibPdf');
  http.Response resPdf = await http.post(urlPdf, headers: headersPdf, body: dataPdf);
  if(resPdf.success) {
    String dir = await AppUtil.createFolderInAppDocDir('pdfs');
    File file = File("$dir/NotamSofia_${airports[0]}-${airports[1]}.pdf");
    await file.writeAsBytes(resPdf.bodyBytes);
    print("Notam Sofia Pdf written");
    return 0;
  }
  else {
    print("Failed to get Notam Sofia");
    return 1;
  }
}