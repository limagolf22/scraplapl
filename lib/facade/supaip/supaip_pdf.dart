import 'dart:io';
import 'package:logger/logger.dart';
import 'package:requests/requests.dart';
import 'package:scraplapl/facade/supaip/supaip_parsing.dart';
import 'package:scraplapl/kernel/supaip/supaip_model.dart';
import 'package:scraplapl/tools.dart';

import 'package:http/http.dart' as http;

var loggerSupAipPdf = Logger();

Future<int> downloadSupAipPdfs(List<SupAip> supaips) async {
  if (supaips.isEmpty) {
    return 0;
  }
  return (await Future.wait(supaips
          .map((sa) => http
              .get(Uri.parse(sa.link))
              .then((res) => savePdf(res, adaptSupAipId(sa))))
          .toList()))
      .reduce((a, b) => a + b);
}

Future<int> savePdf(http.Response res, String id) async {
  String dir = await AppUtil.createFolderInAppDocDir('pdfs');
  File file = File("$dir/SupAip_$id.pdf");
  if (file.existsSync()) {
    loggerSupAipPdf.i("Sup Aip $id already downloaded");
    return 0;
  }
  if (res.success) {
    await file.writeAsBytes(res.bodyBytes);
    loggerSupAipPdf.i("Sup Aip $id Pdf written");
    return 0;
  } else {
    loggerSupAipPdf.w("Failed to get Sup Aip $id");
    return 1;
  }
}
