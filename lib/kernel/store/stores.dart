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
