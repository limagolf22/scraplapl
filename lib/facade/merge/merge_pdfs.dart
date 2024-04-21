import 'dart:io';

import 'package:logger/logger.dart';
import 'package:process_runner/process_runner.dart';
import 'package:scraplapl/facade/azba/azba_pdf.dart';
import 'package:scraplapl/facade/notam/notam_pdf.dart';
import 'package:scraplapl/facade/supaip/supaip_parsing.dart';
import 'package:scraplapl/facade/weather/weather_pdf.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/tools.dart';

var mergeLogger = Logger();

Future<int> mergeAllPdfs(String dep, String arr, String targetedFolder) async {
  var dir = await AppUtil.createFolderInAppDocDir('pdfs');

  saveNotamPdf(dep, arr, pdfDownloads['Notam']!);

  saveWeatherPdf(dep, arr, pdfDownloads['Weather']!);

  saveAzbaPDF(dep, arr);

  List<String> selectedPDFs = [];
  for (var p in [
        "$dir/MTO_$dep-$arr.pdf",
        "$dir/NotamSofia_$dep-$arr.pdf",
        "$dir/Azba_$dep-$arr.pdf",
        "$dir/Conso_$dep-$arr.pdf",
        "$dir/Perfo_$dep-$arr.pdf"
      ] +
      supAips.map((sa) => "$dir/SupAip_${adaptSupAipId(sa)}.pdf").toList()) {
    if (File(p).existsSync()) {
      mergeLogger.d("path exists : " + p);
      selectedPDFs.add(p);
    }
    ;
  }
  ProcessRunner processRunner = ProcessRunner();
  ProcessRunnerResult result = await processRunner.runProcess(
      ['./pdftk/pdftk.exe'] +
          selectedPDFs +
          ['cat', 'output', 'Merged_${targetedFolder}_$dep-$arr.pdf'],
      runInShell: false);
  if (result.exitCode == 0) {
    mergeLogger.i("merge is done succesfully");
    return 0;
  } else {
    mergeLogger.w("failed to merge");
    return 1;
  }
}
