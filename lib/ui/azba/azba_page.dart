import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:scraplapl/facade/azba/azba_pdf.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/main.dart';
import 'package:scraplapl/ui/azba/azba_map.dart';
import 'package:scraplapl/kernel/azba/azba_zone.dart';

void changeAzbaZone(List<AzbaZone> azbaZonesArg) {
  var now = DateTime.now();
  azbaZones = azbaZonesArg;
  activationsTimes = [now] +
      azbaZones
          .map((az) => az.getActivationStarts().union(az.getActivationEnds()))
          .expand((e) => e)
          .where((dt) => dt.isAfter(now))
          .toSet()
          .toList();
  activationsTimes
      .sort((a, b) => a.millisecondsSinceEpoch - b.millisecondsSinceEpoch);
}

class AzbaPageWidget extends StatefulWidget {
  const AzbaPageWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AzbaPageWidgetState();
  }
}

class _AzbaPageWidgetState extends State<AzbaPageWidget> {
  var azbaPageLogger = Logger();
  int _forecastTime = 0;

  @override
  Widget build(BuildContext context) {
    var dateTimeNow = DateTime.now().toUtc();
    if (activationsTimes.isNotEmpty) {
      if (_forecastTime < 0) {
        _forecastTime += activationsTimes.length;
      }
    }
    var dateTime = activationsTimes.isNotEmpty
        ? activationsTimes[_forecastTime % activationsTimes.length]
        : dateTimeNow.add(Duration(hours: _forecastTime));
    azbaPageLogger.i("build azba map with : ${dateTime.toIso8601String()}");

    return Scaffold(
      appBar: AppBar(
        title: const Text('AZBA Map'),
        actions: const [
          IconButton(
            icon: Icon(Icons.save),
            tooltip: 'save as pdf',
            onPressed: saveAzbaPdf,
          )
        ],
      ),
      body: Column(children: [
        Row(children: [
          ElevatedButton(
              onPressed: decreaseForecastTime,
              child: const Text(
                "<",
                style: TextStyle(fontSize: 20),
              )),
          Text(
            frFormatDateTime(dateTime),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
              onPressed: increaseForecastTime,
              child: const Text(">", style: TextStyle(fontSize: 20))),
        ]),
        Expanded(child: AzbaMapWidget(dateTime))
      ]),
    );
  }

  void increaseForecastTime() {
    setState(() {
      _forecastTime++;
    });
  }

  void decreaseForecastTime() {
    setState(() {
      _forecastTime--;
    });
  }
}

String frFormatDateTime(DateTime dateTime) {
  var dt = dateTime.toUtc();
  return "${dt.year}-${add0(dt.month)}-${add0(dt.day)} ${add0(dt.hour)}:${add0(dt.minute)}Z";
}
