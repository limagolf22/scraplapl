import 'package:flutter/material.dart';
import 'package:scraplapl/main.dart';
import 'package:scraplapl/kernel/perfo/pdf_generation.dart';

import '../perfo/perfo_page.dart';

const headersConso = [
  "taxi",
  "vol",
  "app",
  "reroute",
  "marge",
  "final reserve",
  "supplément",
];

var consoContentold = List<int>.generate(headersConso.length, (index) => 0);
var consoContent = {for (var k in headersConso) k: 0};

class FuelPage extends StatefulWidget {
  const FuelPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _FuelPageState();
  }
}

class _FuelPageState extends State<FuelPage> {
  int totalFuel = consoContent.values.reduce((int a, int b) => a + b);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Fuel Page'),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            children: [
              Table(
                  border: TableBorder.all(),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: headersConso
                          .map((h) => TableRow(children: [
                                createCell(Text(
                                  h,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                                ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(minWidth: 60),
                                    child: createCell(TextFormField(
                                        style: const TextStyle(fontSize: 10),
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        controller: TextEditingController()
                                          ..text = consoContent[h].toString()
                                          ..selection = TextSelection.collapsed(
                                              offset: consoContent[h]
                                                  .toString()
                                                  .length),
                                        onChanged: (value) {
                                          try {
                                            consoContent[h] = value == ""
                                                ? 0
                                                : int.parse(value);
                                          } on FormatException {}
                                          setState(() {
                                            totalFuel = consoContent.values
                                                .reduce((a, b) => (a + b));
                                          });
                                        })))
                              ]))
                          .toList() +
                      [
                        TableRow(children: [
                          createCell(const Text(
                            "TOTAL",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          createCell(Text(
                            totalFuel.toString(),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ))
                        ])
                      ]),
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
        )));
  }
}
