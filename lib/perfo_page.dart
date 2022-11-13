import 'package:flutter/material.dart';
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

var perfoContent = List<List<String>>.generate(
    4, (int index) => ["", "", "", "", "", "", "", "", "", ""]);

class PerfoPage extends StatelessWidget {
  const PerfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfo Page'),
      ),
      body: Container(
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
          Image.asset('assets/images/TO-DR400.png'),
          Image.asset('assets/images/LD-DR400.png'),
          Image.asset('assets/images/perfoTab.png')
        ],
      ))),
    );
  }
}

Widget createCell(Widget el) {
  return Padding(padding: const EdgeInsets.all(2.0), child: el);
}
