import 'dart:math';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:requests/requests.dart';
import 'package:scraplapl/facade/supaip/supaip_parsing.dart';
import 'package:scraplapl/kernel/store/stores.dart';

final Set<String> FIRs = {'LFFF', 'LFBB', 'LFRR', 'LFMM', 'LFEE'};

var loggerSupAip = Logger();

Future<int> retrieveAllSupAips(DateTime instant) async {
  supAips = [];
  return (await Future.wait(FIRs.map((fir) => scrapSupAips(instant, fir))))
      .reduce((a, b) => a + b);
}

Future<int> scrapSupAips(DateTime instant, String fir) async {
  var instantAfterDay = instant.add(const Duration(days: 1));

  var res = await scrapSupAipHtml(fir);
  if (res == null) {
    loggerSupAip.w("Failed to scrap SupAip page for FIR $fir");
    return 1;
  }

  supAips.addAll(parseAllSupAip(parseSupAipStringAsHtml(res), fir)
      .where((sa) => sa.isActive(instant) || sa.isActive(instantAfterDay)));
  return 0;
}

Future<String?> scrapSupAipHtml(String fir) async {
  var key = generateFormKeyString();
  var headers = {
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'Cookie': 'form_key=$key',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  var data = 'title=&location=$fir&form_key=$key';

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
