import 'dart:async';

import 'package:flutter/material.dart';
import 'package:process_runner/process_runner.dart';
import 'package:scraplapl/RequestStatus.dart';
import 'package:scraplapl/account_dialog.dart';
import 'package:scraplapl/fuel_page.dart';
import 'package:scraplapl/perfo_page.dart';
import 'package:scraplapl/scrapping.dart';
import 'package:scraplapl/scrapping_Notam.dart';
import 'package:scraplapl/tools.dart';
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

String chosenAircraft = "DR400-120";

String personalFolder = "default";

class MainRoute extends StatefulWidget {
  const MainRoute({super.key});

  @override
  State<MainRoute> createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {
  RequestStatus scrappingNotamStatus = RequestStatus.UNDONE;
  RequestStatus scrappingWeatherStatus = RequestStatus.UNDONE;
  RequestStatus mergeStatus = RequestStatus.UNDONE;

  @override
  void initState() {
    super.initState();

    // simply use this
    Timer.run(() {
      if (personalFolder == "default") {
        open_login_dialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //AppUtil.getDir();

    return Scaffold(
        appBar: AppBar(
          title: Text('MainPage ' + Directory.current.toString()),
          actions: <Widget>[
            IconButton(
              color: const Color.fromARGB(255, 255, 255, 255),
              icon: const Icon(Icons.oil_barrel_rounded),
              tooltip: 'go to fuel page',
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
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              validator: validateICAO,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) {
                depArpt = value.toUpperCase();
                if (scrappingNotamStatus != RequestStatus.UNDONE ||
                    scrappingWeatherStatus != RequestStatus.UNDONE ||
                    mergeStatus != RequestStatus.UNDONE) {
                  setState(() {
                    scrappingNotamStatus = RequestStatus.UNDONE;
                    scrappingWeatherStatus = RequestStatus.UNDONE;
                    mergeStatus = RequestStatus.UNDONE;
                  });
                }
              },
              controller: TextEditingController()..text = depArpt,
              decoration: const InputDecoration(labelText: "DEPARTURE")),
          TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              validator: validateICAO,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) {
                arrArpt = value.toUpperCase();
                if (scrappingNotamStatus != RequestStatus.UNDONE ||
                    scrappingWeatherStatus != RequestStatus.UNDONE ||
                    mergeStatus != RequestStatus.UNDONE) {
                  setState(() {
                    scrappingNotamStatus = RequestStatus.UNDONE;
                    scrappingWeatherStatus = RequestStatus.UNDONE;
                    mergeStatus = RequestStatus.UNDONE;
                  });
                }
              },
              controller: TextEditingController()..text = arrArpt,
              decoration: const InputDecoration(labelText: "ARRIVAL")),
          TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              validator: validateICAO,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) {
                rerouting1 = value.toUpperCase();
                if (scrappingNotamStatus != RequestStatus.UNDONE ||
                    scrappingWeatherStatus != RequestStatus.UNDONE ||
                    mergeStatus != RequestStatus.UNDONE) {
                  setState(() {
                    scrappingNotamStatus = RequestStatus.UNDONE;
                    scrappingWeatherStatus = RequestStatus.UNDONE;
                    mergeStatus = RequestStatus.UNDONE;
                  });
                }
              },
              controller: TextEditingController()..text = rerouting1,
              decoration: const InputDecoration(labelText: "Rerouting1")),
          TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [UpperCaseTextFormatter()],
              validator: validateICAO,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (value) {
                rerouting2 = value.toUpperCase();
                if (scrappingNotamStatus != RequestStatus.UNDONE ||
                    scrappingWeatherStatus != RequestStatus.UNDONE ||
                    mergeStatus != RequestStatus.UNDONE) {
                  setState(() {
                    scrappingNotamStatus = RequestStatus.UNDONE;
                    scrappingWeatherStatus = RequestStatus.UNDONE;
                    mergeStatus = RequestStatus.UNDONE;
                  });
                }
              },
              controller: TextEditingController()..text = rerouting2,
              decoration: const InputDecoration(labelText: "Rerouting2")),
          DropdownButton<String>(
            value: chosenAircraft,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                chosenAircraft = value!;
              });
            },
            items: ["DR400-120", "DR400-140B", "TB10"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(
              child: const Text("upload datas (Notam+Weather)"),
              onPressed: () async {
                var date =
                    DateTime.now().toUtc().add(const Duration(minutes: 5));

                Future<int> exitCodeNotam = getPdfNotamSofia(
                    [depArpt, arrArpt, rerouting1, rerouting2]
                        .where((arpt) => AppUtil.isICAO(arpt))
                        .toList(),
                    "${date.year}/${add0(date.month)}/${add0(date.day)}",
                    "${add0(date.hour)}:${add0(date.minute)}");

                Future<int> exitCodeWeather =
                    getPdfWeather(depArpt, arrArpt, 40);
                List<int> mergeRes =
                    (await Future.wait([exitCodeWeather, exitCodeNotam]));
                setState(() {
                  scrappingNotamStatus = mergeRes[1] == 0
                      ? RequestStatus.SUCCESS
                      : RequestStatus.FAIL;
                  scrappingWeatherStatus = mergeRes[0] == 0
                      ? RequestStatus.SUCCESS
                      : RequestStatus.FAIL;
                });
              },
            ),
            iconRequestStatus(scrappingNotamStatus),
            iconRequestStatus(scrappingWeatherStatus)
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(
                child: const Text("merge pdf"),
                onPressed: () async {
                  var dir = await AppUtil.createFolderInAppDocDir('pdfs');
                  print(dir);
                  List<String> selectedPDFs = [];
                  for (var p in [
                    "$dir/MTO_$depArpt-$arrArpt.pdf",
                    "$dir/NotamSofia_$depArpt-$arrArpt.pdf",
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
                  ProcessRunner processRunner = ProcessRunner();
                  ProcessRunnerResult result = await processRunner.runProcess(
                      ['./pdftk/pdftk.exe'] +
                          selectedPDFs +
                          [
                            'cat',
                            'output',
                            '${personalFolder}_$depArpt-$arrArpt.pdf'
                          ],
                      runInShell: false);
                  print(result.exitCode == 0
                      ? "merge is done succesfully"
                      : "failed to merge");
                  setState(() {
                    mergeStatus = result.exitCode == 0
                        ? RequestStatus.SUCCESS
                        : RequestStatus.FAIL;
                  });
                }),
            iconRequestStatus(mergeStatus)
          ])
        ]));
  }
}

String add0(int num) {
  return num < 10 ? "0$num" : num.toString();
}

Icon iconRequestStatus(RequestStatus reqStatus) {
  switch (reqStatus) {
    case RequestStatus.UNDONE:
      return Icon(Icons.change_circle_outlined, color: Colors.transparent);
    case RequestStatus.SUCCESS:
      return Icon(Icons.check_rounded, color: Colors.green);
    case RequestStatus.FAIL:
      return Icon(Icons.error_outline, color: Colors.red);
    default:
      return Icon(Icons.change_circle_outlined, color: Colors.transparent);
  }
}

String? validateICAO(String? icao) {
  return (icao != null && !AppUtil.isICAO(icao)) ? "not ICAO format" : null;
}
