import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/main.dart';
import 'package:scraplapl/ui/azba/azba_map.dart';
import 'package:scraplapl/kernel/azba/azba_zone.dart';

void changeAzbaZone(List<AzbaZone> _azbaZones) {
  var now = DateTime.now();
  azbaZones = _azbaZones;
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
    azbaPageLogger.i("build azba map with : " + dateTime.toIso8601String());

    return Scaffold(
      appBar: AppBar(
        title: Text('AZBA Map'),
      ),
      body: Column(children: [
        Row(children: [
          ElevatedButton(
              onPressed: decreaseForecastTime,
              child: const Text(
                "<",
                style: TextStyle(fontSize: 20),
              )),
          ElevatedButton(
              onPressed: increaseForecastTime,
              child: const Text(">", style: TextStyle(fontSize: 20))),
          Text(
            "  Instant : " + frFormatDateTime(dateTime),
            style: TextStyle(fontWeight: FontWeight.bold),
          )
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
