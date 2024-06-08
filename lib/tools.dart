import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scraplapl/main.dart';

class AppUtil {
  static Logger logger = Logger();
  static Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final String relPath = (await createPersonalFolder(appDocDir.path));
    final Directory appDocDirFolder = Directory(
        relPath + (relPath.endsWith("/") ? folderName : "/$folderName"));

    if (await appDocDirFolder.exists()) {
      //if folder already exists return path
      return appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory appDocDirNewFolder =
          await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path;
    }
  }

  static Future<String> createPersonalFolder(String root) async {
    final Directory appDocDirFolder = Directory('$root/$personalFolder/');

    if (await appDocDirFolder.exists()) {
      //if folder already exists return path
      final Directory appDocDirFolder = Directory('$root/$personalFolder/');
      return appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory appDocDirNewFolder =
          await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path;
    }
  }

  static String extDir = "";

  static Future<String?> getExtDir() async {
    var directory = await getExternalStorageDirectory();
    logger.d(
        "External storage dir : ${directory != null ? directory.path : "Storage unavailable"}");
    return directory?.path;
  }

  static bool isICAO(String arpt) {
    return RegExp(r"^[A-Z]{4}$").hasMatch(arpt);
  }

  static bool isCorrectPersonalFolder(String folder) {
    return RegExp(r'^\w+$').hasMatch(folder);
  }
}
