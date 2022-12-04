import 'package:flutter/material.dart';
import 'package:scraplapl/ResizableImage.dart';
import 'package:scraplapl/scrapping.dart';

import 'main.dart';

const headersPerfo = [
  "OACI",
  "alti(ft)",
  "T(°C)",
  "vent(kts)",
  "herbe",
  "TOD",
  "TODA",
  "LD  ",
  "LDA"
];

const headerPerfsInputs = ["alti(ft)", "T(°C)", "vent(kts)", "herbe"];
const headerPerfsOutputs = ["TOD", "TODA", "LD", "LDA"];

List<String> airportsPerfs = ["","","",""];

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
      child: Column(children:[TextFormField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.name,
          onChanged: (value) {
            airportsPerfs[i] = value;
          },
          controller: TextEditingController()
            ..text = airportsPerfs[i],
          decoration: InputDecoration(labelText: "Airport",constraints: BoxConstraints(maxWidth: 100))),Row(
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
                  decoration: InputDecoration(labelText: h,constraints: BoxConstraints(maxWidth: 100))))
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
                decoration: InputDecoration(labelText: "TOD",constraints: BoxConstraints(maxWidth: 100),filled:true, fillColor: Colors.lightBlueAccent)),
            TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  perfsResults[i]["TODA"] = value;
                },
                controller: TextEditingController()
                  ..text = (perfsResults[i]["TODA"]).toString(),
                decoration: InputDecoration(labelText: "TODA",constraints: BoxConstraints(maxWidth: 100),filled:true,fillColor: Colors.lightBlue))
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
                decoration: InputDecoration(labelText: "LD",constraints: BoxConstraints(maxWidth: 100),filled:true,fillColor: Colors.lightGreenAccent)),
            TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  perfsResults[i]["LDA"] = value;
                },
                controller: TextEditingController()
                  ..text = (perfsResults[i]["LDA"]).toString(),
                decoration: InputDecoration(labelText: "LDA",constraints: BoxConstraints(maxWidth: 100),filled:true,fillColor: Colors.lightGreen))
          ],
        )
      ])
    ],
  ), Padding(
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
    Image.asset('assets/images/perfoTab-$chosenAircraft.png')]));
}

Widget createCell(Widget el) {
  return Padding(padding: const EdgeInsets.all(2.0), child: el);
}
/*  Container(
          child: SingleChildScrollView(
              child: Column(
        children: [
          Table(
            border: TableBorder.all(),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [0, 1, 2, 3, 4].map((row) {
              if (row == 0) {
                return TableRow(
                  children: headersPerfo.asMap().entries.map((te) {
                    return createCell(Text(
                      te.value,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 10),
                    ));
                  }).toList(),
                );
              } else {
                return TableRow(
                    children: headersPerfo.asMap().entries.map((col) {
                  return createCell(TextField(
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                      keyboardType: col.key == 0
                          ? TextInputType.text
                          : TextInputType.number,
                      onChanged: (value) {
                        perfoContent[row - 1][col.key] = value;
                        print(perfoContent);
                      },
                      controller: TextEditingController()
                        ..text = perfoContent[row - 1][col.key]));
                }).toList());
              }
            }).toList(),
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
          Image.asset('assets/images/TO-DR400-120.png'),
          Image.asset('assets/images/LD-DR400.png'),
          Image.asset('assets/images/perfoTab-DR400-120.png')
        ],
      ))),*/
