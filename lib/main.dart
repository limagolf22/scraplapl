import 'package:flutter/material.dart';
import 'package:scraplapl/FuelPage.dart';
import 'package:scraplapl/PerfoPage.dart';
import 'package:scraplapl/scrapping.dart';
import 'package:scraplapl/tools.dart';
import 'package:pdf_merger/pdf_merger.dart';
import 'dart:io';

void main() {
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
          title: const Text('MainPage'),
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
          Row(children: [
            const Text("DEP :           "),
            Expanded(
              child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    depArpt = value;
                  },
                  controller: TextEditingController()..text = depArpt),
            )
          ]),
          Row(children: [
            const Text("ARR :           "),
            Expanded(
              child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    arrArpt = value;
                  },
                  controller: TextEditingController()..text = arrArpt),
            )
          ]),
          Row(children: [
            const Text("Rerouting1 : "),
            Expanded(
              child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    rerouting1 = value;
                  },
                  controller: TextEditingController()..text = rerouting1),
            )
          ]),
          Row(children: [
            const Text("Rerouting2 : "),
            Expanded(
              child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    rerouting2 = value;
                  },
                  controller: TextEditingController()..text = rerouting2),
            )
          ]),
          TextButton(
            child: const Text("upload datas"),
            onPressed: () {
              //getPdfNotam(["LFBO", "LFMT"], "2022/07/28", "00:25");
              getPdfWeather(depArpt, arrArpt, 40);
              var date = DateTime.now().toUtc().add(const Duration(minutes: 5));
              getPdfNotam(
                  [depArpt, arrArpt],
                  "${date.year}/${add0(date.month)}/${date.day}",
                  "${date.hour}:${date.minute}");
            },
          ),
          TextButton(
              child: const Text("merge pdf"),
              onPressed: () async {
                var dir = await AppUtil.createFolderInAppDocDir('pdfs');
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
                MergeMultiplePDFResponse response =
                    await PdfMerger.mergeMultiplePDF(
                        paths: selectedPDFs,
                        outputDirPath:
                            AppUtil.extDir + "/merged_$depArpt-$arrArpt.pdf");

                print(response.status);
              })
        ]));
  }
}

String add0(int num) {
  return num < 10 ? "0$num" : num.toString();
}
