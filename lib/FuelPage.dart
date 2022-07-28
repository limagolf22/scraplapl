import 'package:flutter/material.dart';
import 'package:scraplapl/main.dart';
import 'package:scraplapl/scrapping.dart';

import 'PerfoPage.dart';

const headersConso = [
  "taxi",
  "vol",
  "app",
  "reroute",
  "marge",
  "final res",
  "supp",
];

var consoContent = new List<int>.generate(headersConso.length, (index) => 0);

class FuelPage extends StatefulWidget {
  FuelPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FuelPageState();
  }
}

class _FuelPageState extends State<FuelPage> {
  int totalFuel = 0;
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < consoContent.length; i++) {
      consoContent[i] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Fuel Page'),
        ),
        body: Container(
            child: SingleChildScrollView(
                child: Center(
          child: Column(
            children: [
              Table(
                border: TableBorder.all(),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  TableRow(
                    children: headersConso.asMap().entries.map((te) {
                          return createRow(Text(
                            te.value,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ));
                        }).toList() +
                        [
                          createRow(const Text("total",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors.yellow)))
                        ],
                  ),
                  TableRow(
                      children: headersConso.asMap().entries.map((col) {
                            return createRow(TextField(
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  consoContent[col.key] =
                                      value == "" ? 0 : int.parse(value);
                                  setState(() {
                                    totalFuel =
                                        consoContent.reduce((a, b) => (a + b));
                                  });
                                }));
                          }).toList() +
                          [
                            createRow(TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                enabled: false,
                                controller: TextEditingController()
                                  ..text = totalFuel.toString()))
                          ])
                ],
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 0),
                  child: TextButton(
                      onPressed: () {
                        if (depArpt != "" && arrArpt != "") {
                          createConsoPDF([depArpt, arrArpt]);
                        }
                      },
                      child: const Text("Valider")))
            ],
          ),
        ))));
  }
}
