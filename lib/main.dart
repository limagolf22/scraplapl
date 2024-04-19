import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:process_runner/process_runner.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/ui/formatter.dart';
import 'package:scraplapl/ui/request_status.dart';
import 'package:scraplapl/facade/supaip/supaip_scrapping.dart';
import 'package:scraplapl/facade/supaip/supaip_parsing.dart';
import 'package:scraplapl/ui/account/account_dialog.dart';
import 'package:scraplapl/ui/azba/azba_map.dart';
import 'package:scraplapl/facade/azba/azba_scrapping.dart';
import 'package:scraplapl/ui/fuel/fuel_page.dart';
import 'package:scraplapl/ui/perfo/perfo_page.dart';
import 'package:scraplapl/tools.dart';
import 'package:scraplapl/facade/notam/notam_scrapping.dart';
import 'package:scraplapl/facade/weather/weather_scrapping.dart';
import 'package:scraplapl/ui/supaip/table_supaip.dart';

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

final PLANE_TYPES = {"DR400-120", "DR400-140B", "TB10"};

String chosenAircraft = PLANE_TYPES.first;

String personalFolder = "default";

class MainRoute extends StatefulWidget {
  const MainRoute({super.key});

  @override
  State<MainRoute> createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {
  RequestStatus scrappingNotamStatus = RequestStatus.UNDONE;
  RequestStatus scrappingWeatherStatus = RequestStatus.UNDONE;
  RequestStatus azbaStatus = RequestStatus.UNDONE;
  RequestStatus supAipStatus = RequestStatus.UNDONE;

  RequestStatus mergeStatus = RequestStatus.UNDONE;

  Logger logger = new Logger();

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
              icon: const Icon(Icons.flight_takeoff),
              tooltip: 'go to perfo page',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfoPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.format_shapes_sharp),
              tooltip: 'go to azba page',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AzbaMapWidget()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.warning_amber_rounded),
              tooltip: 'go to supaip page',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SupAipTable()),
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
                resetAllStatus();
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
                resetAllStatus();
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
                resetAllStatus();
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
                resetAllStatus();
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
            items: PLANE_TYPES.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(
              child: const Text("upload datas (Notam+Weather+AZBA)"),
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

                Future<int> exitCodeAzba = scrapPdfAllAzba(depArpt, arrArpt);

                Future<int> exitCodeSupAip = retrieveAllSupAips(date);

                List<int> mergeRes = (await Future.wait([
                  exitCodeNotam,
                  exitCodeWeather,
                  exitCodeAzba,
                  exitCodeSupAip
                ]));
                setState(() {
                  scrappingNotamStatus = mergeRes[0] == 0
                      ? RequestStatus.SUCCESS
                      : RequestStatus.FAIL;
                  scrappingWeatherStatus = mergeRes[1] == 0
                      ? RequestStatus.SUCCESS
                      : RequestStatus.FAIL;
                  azbaStatus = mergeRes[2] == 0
                      ? RequestStatus.SUCCESS
                      : RequestStatus.FAIL;
                  supAipStatus = mergeRes[3] == 0
                      ? RequestStatus.SUCCESS
                      : RequestStatus.FAIL;
                });
              },
            ),
            iconRequestStatus(scrappingNotamStatus, "Notam scrapping status"),
            iconRequestStatus(
                scrappingWeatherStatus, "Weather scrapping status"),
            iconRequestStatus(azbaStatus, "Azba scrapping status"),
            iconRequestStatus(supAipStatus, "SupAip scrapping status")
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton(
                child: const Text("merge pdf"),
                onPressed: () async {
                  var dir = await AppUtil.createFolderInAppDocDir('pdfs');
                  logger.d(dir);
                  List<String> selectedPDFs = [];
                  for (var p in [
                        "$dir/MTO_$depArpt-$arrArpt.pdf",
                        "$dir/NotamSofia_$depArpt-$arrArpt.pdf",
                        "$dir/Azba_$depArpt-$arrArpt.pdf",
                        "$dir/Conso_$depArpt-$arrArpt.pdf",
                        "$dir/Perfo_$depArpt-$arrArpt.pdf"
                      ] +
                      supAips
                          .map((sa) => "$dir/SupAip_${adaptSupAipId(sa)}.pdf")
                          .toList()) {
                    if (File(p).existsSync()) {
                      logger.d("path exists : " + p);
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
                            'Merged_${personalFolder}_$depArpt-$arrArpt.pdf'
                          ],
                      runInShell: false);
                  if (result.exitCode == 0) {
                    logger.i("merge is done succesfully");
                  } else {
                    logger.w("failed to merge");
                  }
                  setState(() {
                    mergeStatus = result.exitCode == 0
                        ? RequestStatus.SUCCESS
                        : RequestStatus.FAIL;
                  });
                }),
            iconRequestStatus(mergeStatus, "Pdf Merge Status")
          ])
        ]));
  }

  void resetAllStatus() {
    if (scrappingNotamStatus != RequestStatus.UNDONE ||
        scrappingWeatherStatus != RequestStatus.UNDONE ||
        azbaStatus != RequestStatus.UNDONE ||
        supAipStatus != RequestStatus.UNDONE ||
        mergeStatus != RequestStatus.UNDONE) {
      setState(() {
        scrappingNotamStatus = RequestStatus.UNDONE;
        scrappingWeatherStatus = RequestStatus.UNDONE;
        azbaStatus = RequestStatus.UNDONE;
        supAipStatus = RequestStatus.UNDONE;
        mergeStatus = RequestStatus.UNDONE;
      });
    }
  }
}

String add0(int num) {
  return num < 10 ? "0$num" : num.toString();
}

Widget iconRequestStatus(RequestStatus reqStatus, String tooltip) {
  switch (reqStatus) {
    case RequestStatus.UNDONE:
      return Tooltip(
          message: tooltip,
          child: Icon(Icons.change_circle_outlined, color: Colors.transparent));
    case RequestStatus.SUCCESS:
      return Tooltip(
          message: tooltip,
          child: Icon(Icons.check_rounded, color: Colors.green));
    case RequestStatus.FAIL:
      return Tooltip(
          message: tooltip,
          child: Icon(Icons.error_outline, color: Colors.red));
    default:
      return Tooltip(
          message: tooltip,
          child: Icon(Icons.change_circle_outlined, color: Colors.transparent));
  }
}

String? validateICAO(String? icao) {
  return (icao != null && !AppUtil.isICAO(icao)) ? "not ICAO format" : null;
}
