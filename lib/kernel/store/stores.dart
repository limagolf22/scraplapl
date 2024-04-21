import 'dart:typed_data';

import 'package:scraplapl/kernel/airplane/fuel.dart';
import 'package:scraplapl/kernel/airplane/perfo.dart';
import 'package:scraplapl/kernel/azba/azba_zone.dart';
import 'package:scraplapl/kernel/supaip/supaip_model.dart';

List<AzbaZone> azbaZones = [];
List<DateTime> activationsTimes = [];

List<SupAip> supAips = [];

List<String> airportsPerfs = ["", "", "", ""];

Map<String, int> consoContent = {for (var k in headersConso) k: 0};

List<Map<String, String>> perfsInputs = [
  {for (var h in headerPerfsInputs) h: ""},
  {for (var h in headerPerfsInputs) h: ""},
  {for (var h in headerPerfsInputs) h: ""},
  {for (var h in headerPerfsInputs) h: ""}
];

List<Map<String, String>> perfsResults = [
  {for (var h in headerPerfsOutputs) h: ""},
  {for (var h in headerPerfsOutputs) h: ""},
  {for (var h in headerPerfsOutputs) h: ""},
  {for (var h in headerPerfsOutputs) h: ""}
];

Map<String, Uint8List> pdfDownloads = {
  "Notam": Uint8List(0),
  "Weather": Uint8List(0),
  "Conso": Uint8List(0),
  "Perfo": Uint8List(0),
  "Azba": Uint8List(0),
  "SupAip": Uint8List(0)
};
