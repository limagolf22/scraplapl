import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:scraplapl/facade/merge/merge_pdfs.dart';
import 'package:scraplapl/ui/azba/azba_page.dart';
import 'package:scraplapl/ui/formatter.dart';
import 'package:scraplapl/ui/request_status.dart';
import 'package:scraplapl/facade/supaip/supaip_scrapping.dart';
import 'package:scraplapl/ui/account/account_dialog.dart';
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

const planeTypes = {"DR400-120", "DR400-140B", "TB10"};
String chosenAircraft = planeTypes.first;

String personalFolder = "default";

Logger logger = Logger();

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

  @override
  void initState() {
    super.initState();

    Timer.run(() {
      if (personalFolder == "default") {
        openLoginDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //AppUtil.getDir();

    return Scaffold(
        appBar: AppBar(
          title: Text('MainPage ${Directory.current}'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.oil_barrel_rounded),
              tooltip: 'go to fuel page',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FuelPage()),
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
                  MaterialPageRoute(
                      builder: (context) => const AzbaPageWidget()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.warning_amber_rounded),
              tooltip: 'go to supaip page',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupAipTable()),
                );
              },
            )
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                items: planeTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                iconRequestStatus(
                    scrappingNotamStatus, "Notam scrapping status"),
                iconRequestStatus(
                    scrappingWeatherStatus, "Weather scrapping status"),
                ElevatedButton(
                  child: const Text("upload datas"),
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
                        getPdfWeatherSofia(depArpt, arrArpt, date);

                    Future<int> exitCodeAzba =
                        scrapPdfAllAzba(depArpt, arrArpt);

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
                iconRequestStatus(azbaStatus, "Azba scrapping status"),
                iconRequestStatus(supAipStatus, "SupAip scrapping status")
              ]),
              const SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                    onPressed: mergePdfPressed, child: const Text("merge pdf")),
                iconRequestStatus(mergeStatus, "Pdf Merge Status")
              ])
            ])));
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

  void mergePdfPressed() async {
    int res = await mergeAllPdfs(depArpt, arrArpt, personalFolder);
    setState(() {
      mergeStatus = res == 0 ? RequestStatus.SUCCESS : RequestStatus.FAIL;
    });
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
          child:
              null); //Icon(Icons.change_circle_outlined, color: Colors.transparent));
    case RequestStatus.SUCCESS:
      return Tooltip(
          message: tooltip,
          child: const Icon(Icons.check_rounded, color: Colors.green));
    case RequestStatus.FAIL:
      return Tooltip(
          message: tooltip,
          child: const Icon(Icons.error_outline, color: Colors.red));
    default:
      return Tooltip(
          message: tooltip,
          child: const Icon(Icons.change_circle_outlined,
              color: Colors.transparent));
  }
}

String? validateICAO(String? icao) {
  return (icao != null && !AppUtil.isICAO(icao)) ? "not ICAO format" : null;
}
