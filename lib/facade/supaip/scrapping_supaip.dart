import 'dart:io';
import 'dart:math';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:requests/requests.dart';
import 'package:scraplapl/facade/supaip/supaip_parsing.dart';
import 'package:scraplapl/kernel/supaip/supaip_model.dart';

import '../../tools.dart';

var loggerSupAip = Logger();

List<SupAip> supAips = [];

Future<int> retrieveSupAipPdfs(DateTime instant) async {
  if (await scrapSupAips(instant) != 0) {
    return 1;
  }

  return (await Future.wait(supAips
          .map((sa) => http
              .get(Uri.parse(sa.link))
              .then((res) => savePdf(res, adaptSupAipId(sa))))
          .toList()))
      .reduce((a, b) => a + b);
}

Future<int> scrapSupAips(DateTime instant) async {
  var instantAfterDay = instant.add(const Duration(days: 1));

  var res = await scrapSupAipHtml();
  if (res == null) {
    loggerSupAip.w("Failed to scrap SupAip page");
    return 1;
  }

  supAips = parseAllSupAip(parseSupAipStringAsHtml(res))
      .where((sa) => sa.isActive(instant) || sa.isActive(instantAfterDay))
      .toList();
  return 0;
}

Future<int> savePdf(http.Response res, String id) async {
  String dir = await AppUtil.createFolderInAppDocDir('pdfs');
  File file = File("$dir/SupAip_$id.pdf");
  if (file.existsSync()) {
    loggerSupAip.i("Sup Aip $id already downloaded");
    return 0;
  }
  if (res.success) {
    await file.writeAsBytes(res.bodyBytes);
    loggerSupAip.i("Sup Aip $id Pdf written");
    return 0;
  } else {
    loggerSupAip.w("Failed to get Sup Aip $id");
    return 1;
  }
}

Future<String?> scrapSupAipHtml() async {
  var key = generateFormKeyString();
  var headers = {
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'Cookie': 'form_key=$key',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  var data = 'title=&location=LFBB&form_key=$key';

  var url = Uri.parse(
      'https://www.sia.aviation-civile.gouv.fr/documents/supaip/aip/id/6');
  var res = await http.post(url, headers: headers, body: data);

  return res.success ? res.content() : null;
}

List<Element> parseSupAipStringAsHtml(String htmlStr) {
  var doc = parse(htmlStr);
  return doc.querySelectorAll('tr.tr_ligne_document');
}

String generateFormKeyString() {
  var length = 16,
      chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  var rng = Random();
  return Iterable.generate(length, (i) => chars[rng.nextInt(chars.length)])
      .join();
}
