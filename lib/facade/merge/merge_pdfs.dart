import 'dart:io';

import 'package:logger/logger.dart';
import 'package:process_runner/process_runner.dart';
import 'package:scraplapl/facade/airplane/conso_pdf.dart';
import 'package:scraplapl/facade/airplane/perfo_pdf.dart';
import 'package:scraplapl/facade/azba/azba_pdf.dart';
import 'package:scraplapl/facade/notam/notam_pdf.dart';
import 'package:scraplapl/facade/supaip/supaip_parsing.dart';
import 'package:scraplapl/facade/supaip/supaip_pdf.dart';
import 'package:scraplapl/facade/weather/weather_pdf.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/tools.dart';
import 'package:pdf_merger/pdf_merger.dart';

var mergeLogger = Logger();

Future<int> mergeAllPdfs(String dep, String arr, String targetedFolder) async {
  switch (Platform.operatingSystem) {
    case "windows":
      return saveAllFiles(dep, arr)
          .then((_) => mergeAllPdfsWindows(dep, arr, targetedFolder));
    case "android":
      return saveAllFiles(dep, arr)
          .then((_) => mergeAllPdfsAndroid(dep, arr, targetedFolder));
    default:
      return 1;
  }
}

Future<int> mergeAllPdfsWindows(
    String dep, String arr, String targetedFolder) async {
  var dir = await AppUtil.createFolderInAppDocDir('pdfs');

  List<String> selectedPDFs = generateExistingPdfFileList(dir, dep, arr);
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

Future<int> mergeAllPdfsAndroid(
    String dep, String arr, String targetedFolder) async {
  var extDir = await AppUtil.getExtDir();
  if (extDir == null) {
    mergeLogger.w("External Directory not available, failed to merge");
    return 1;
  }

  mergeLogger.d("external directory found for merge : $extDir");

  var dir = await AppUtil.createFolderInAppDocDir('pdfs');
  mergeLogger.d("internal directory found : $dir");

  List<String> selectedPDFs = generateExistingPdfFileList(dir, dep, arr);

  MergeMultiplePDFResponse response = await PdfMerger.mergeMultiplePDF(
      paths: selectedPDFs,
      outputDirPath: "$extDir/Merged_${targetedFolder}_$dep-$arr.pdf");

  mergeLogger.d("result of merge :");
  mergeLogger.d(response.status);
  mergeLogger.d(response.message);
  mergeLogger.d(response.response);

  if (response.status == "success") {
    mergeLogger.i("merge is done succesfully");
    return 0;
  } else {
    mergeLogger.w("failed to merge");
    return 1;
  }
}

List<String> generateExistingPdfFileList(String dir, String dep, String arr) {
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
      mergeLogger.d("path exists : $p");
      selectedPDFs.add(p);
    } else {
      mergeLogger.d("path does not exist : $p");
    }
  }
  return selectedPDFs;
}

Future<void> saveAllFiles(String dep, String arr) async {
  await fileSaveNotamPdf(dep, arr, pdfDownloads['Notam']!);

  await fileSaveWeatherPdf(dep, arr, pdfDownloads['Weather']!);

  await fileSaveAzbaPDF(dep, arr);

  await fileSaveSupAipPdfs();

  await fileSaveConsoPDF([dep, arr]);

  await fileSavePerfoPDF([dep, arr]);
}
