import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scraplapl/main.dart';

class AppUtil {
  static Logger logger = new Logger();
  static Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder = Directory(
        (await createPersonalFolder(_appDocDir.path)) + "/$folderName");

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  static Future<String> createPersonalFolder(String root) async {
    final Directory _appDocDirFolder = Directory('${root}/$personalFolder/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      final Directory _appDocDirFolder = Directory('${root}/$personalFolder/');
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  static String extDir = "";

  static Future<void> getDir() async {
    var directory = await getExternalStorageDirectory();
    extDir = directory!.path;
    logger.d("External storage dir : " + extDir);
  }

  static bool isICAO(String arpt) {
    return RegExp(r"^[A-Z]{4}$").hasMatch(arpt);
  }

  static bool isCorrectPersonalFolder(String folder) {
    return RegExp(r'^\w+$').hasMatch(folder);
  }
}
