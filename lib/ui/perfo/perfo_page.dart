import 'package:flutter/material.dart';
import 'package:scraplapl/ui/perfo/ResizableImage.dart';
import 'package:scraplapl/kernel/perfo/pdf_generation.dart';
import 'package:scraplapl/tools.dart';

import '../../main.dart';

const headerPerfsInputs = ["alti(ft)", "T(°C)", "vent(kts)", "herbe"];
const headerPerfsOutputs = ["TOD", "TODA", "LD", "LDA"];

List<String> airportsPerfs = ["", "", "", ""];

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

class PerfoPage extends StatelessWidget {
  const PerfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
              title: const Text('Perfo Page'),
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.flight_takeoff)),
                  Tab(icon: Icon(Icons.flight_land)),
                  Tab(icon: Icon(Icons.flight_land_sharp)),
                  Tab(icon: Icon(Icons.flight_land_sharp)),
                ],
              )),
          body: TabBarView(
            children: [
              perfoFormWidget(0),
              perfoFormWidget(1),
              perfoFormWidget(2),
              perfoFormWidget(3),
            ],
          ),
        ));
  }
}

Widget perfoFormWidget(int i) {
  return SingleChildScrollView(
      child: Column(children: [
    TextFormField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [UpperCaseTextFormatter()],
        validator: validateICAO,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          airportsPerfs[i] = value;
        },
        controller: TextEditingController()..text = airportsPerfs[i],
        decoration: InputDecoration(
            labelText: "Airport", constraints: BoxConstraints(maxWidth: 100))),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
            children: headerPerfsInputs
                .map((h) => TextFormField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      perfsInputs[i][h] = value;
                    },
                    controller: TextEditingController()
                      ..text = (perfsInputs[i][h]).toString(),
                    decoration: InputDecoration(
                        labelText: h,
                        constraints: BoxConstraints(maxWidth: 100))))
                .toList()),
        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
            children: [
              TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    perfsResults[i]["TOD"] = value;
                  },
                  controller: TextEditingController()
                    ..text = (perfsResults[i]["TOD"]).toString(),
                  decoration: InputDecoration(
                      labelText: "TOD",
                      constraints: BoxConstraints(maxWidth: 100),
                      filled: true,
                      fillColor: Colors.lightBlueAccent)),
              TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    perfsResults[i]["TODA"] = value;
                  },
                  controller: TextEditingController()
                    ..text = (perfsResults[i]["TODA"]).toString(),
                  decoration: InputDecoration(
                      labelText: "TODA",
                      constraints: BoxConstraints(maxWidth: 100),
                      filled: true,
                      fillColor: Colors.lightBlue))
            ],
          ),
          Column(
            children: [
              TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    perfsResults[i]["LD"] = value;
                  },
                  controller: TextEditingController()
                    ..text = (perfsResults[i]["LD"]).toString(),
                  decoration: InputDecoration(
                      labelText: "LD",
                      constraints: BoxConstraints(maxWidth: 100),
                      filled: true,
                      fillColor: Colors.lightGreenAccent)),
              TextFormField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    perfsResults[i]["LDA"] = value;
                  },
                  controller: TextEditingController()
                    ..text = (perfsResults[i]["LDA"]).toString(),
                  decoration: InputDecoration(
                      labelText: "LDA",
                      constraints: BoxConstraints(maxWidth: 100),
                      filled: true,
                      fillColor: Colors.lightGreen))
            ],
          )
        ])
      ],
    ),
    Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 0),
        child: TextButton(
            onPressed: () {
              if (depArpt != "" && arrArpt != "") {
                createPerfoPDF([depArpt, arrArpt]);
              }
            },
            child: const Text("Valider"))),
    ResizableImage(imgPath: "TO-$chosenAircraft"),
    ResizableImage(imgPath: "LD-$chosenAircraft"),
    ResizableImage(imgPath: "perfoTab-$chosenAircraft")
  ]));
}

Widget createCell(Widget el) {
  return Padding(padding: const EdgeInsets.all(2.0), child: el);
}
