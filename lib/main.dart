import 'package:flutter/material.dart';
import 'package:process_runner/process_runner.dart';
import 'package:scraplapl/fuel_page.dart';
import 'package:scraplapl/perfo_page.dart';
import 'package:scraplapl/scrapping.dart';
import 'package:scraplapl/tools.dart';
import 'package:pdf_merger/pdf_merger.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MaterialApp(
    title: 'Nav Preparation',
    home: MainRoute(),
  ));
}

String depArpt = "";
String arrArpt = "";
String rerouting1 = "";
String rerouting2 = "";

class MainRoute extends StatelessWidget {
  const MainRoute({super.key});

  @override
  Widget build(BuildContext context) {
    //AppUtil.getDir();
    return Scaffold(
        appBar: AppBar(
          title: Text('MainPage '+Directory.current.toString()),
          actions: <Widget>[
            IconButton(
              color: const Color.fromARGB(255, 255, 255, 255),
              icon: const Icon(Icons.oil_barrel_rounded),
              tooltip: 'go to oil page',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FuelPage()),
                );
              },
            ),
            IconButton(
              color: const Color.fromARGB(255, 255, 255, 255),
              icon: const Icon(Icons.flight_takeoff),
              tooltip: 'go to perfo page',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfoPage()),
                );
              },
            )
          ],
        ),
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                depArpt = value;
              },
              controller: TextEditingController()..text = depArpt,
              decoration: const InputDecoration(labelText: "DEPARTURE")),
          TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                arrArpt = value;
              },
              controller: TextEditingController()..text = arrArpt,
              decoration: const InputDecoration(labelText: "ARRIVAL")),
          TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                rerouting1 = value;
              },
              controller: TextEditingController()..text = rerouting1,
              decoration: const InputDecoration(labelText: "Rerouting1")),
          TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              onChanged: (value) {
                rerouting2 = value;
              },
              controller: TextEditingController()..text = rerouting2,
              decoration: const InputDecoration(labelText: "Rerouting2")),
          TextButton(
            child: const Text("upload datas (Notam+Weather)"),
            onPressed: () {
              var date = DateTime.now().toUtc().add(const Duration(minutes: 5));

              getNotamSofia([depArpt, arrArpt],"${date.year}/${add0(date.month)}/${add0(date.day)}",
                  "${add0(date.hour)}:${add0(date.minute)}");
            //    getNotamSofiaPDF();


              //getPdfNotam(["LFBO", "LFMT"], "2022/07/28", "00:25");
/*              getPdfWeather(depArpt, arrArpt, 40);
              var date = DateTime.now().toUtc().add(const Duration(minutes: 5));
              getPdfNotam(
                  [depArpt, arrArpt],
                  "${date.year}/${add0(date.month)}/${date.day}",
                  "${date.hour}:${date.minute}");*/
            },
          ),
          TextButton(
              child: const Text("merge pdf"),
              onPressed: () async {
                var dir = await AppUtil.createFolderInAppDocDir('pdfs');
                print(dir);
                List<String> selectedPDFs = [];
                for (var p in [
                  "$dir/MTO_$depArpt-$arrArpt.pdf",
                  "$dir/Notam_$depArpt-$arrArpt.pdf",
                  "$dir/Conso_$depArpt-$arrArpt.pdf",
                  "$dir/Perfo_$depArpt-$arrArpt.pdf"
                ]) {
                  if (await File(p).exists()) {
                    print("path exists : " + p);
                    selectedPDFs.add(p);
                  }
                  ;
                }
        /*        MergeMultiplePDFResponse response =
                    await PdfMerger.mergeMultiplePDF(
                        paths: selectedPDFs,
                        outputDirPath:
                            AppUtil.extDir + "/merged_$depArpt-$arrArpt.pdf");

                print(response.status);
*/
                //ProcessRunner processRunner = ProcessRunner();
                //ProcessRunnerResult result = await processRunner.runProcess(['./pdftk/pdftk.exe']+selectedPDFs+[ 'cat', 'output', 'Merged_$depArpt-$arrArpt.pdf'],runInShell: false);

              })
        ]));
  }
}

String add0(int num) {
  return num < 10 ? "0$num" : num.toString();
}
