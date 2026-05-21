import 'dart:io';

import 'package:scraplapl/tools.dart';

Future<List<String>?> retrieveMergedPdfs() async {
  switch (Platform.operatingSystem) {
    case "windows":
      return Directory.current.listSync().where((f) => f.path.endsWith(".pdf")).map((f) => f.path).toList();
    case "android":
      return AppUtil.getFilesInExtDir();
    default:
      return Future.value([]);
  }
}
