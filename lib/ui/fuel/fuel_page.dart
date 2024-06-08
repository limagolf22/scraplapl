import 'package:flutter/material.dart';
import 'package:scraplapl/facade/airplane/conso_pdf.dart';
import 'package:scraplapl/kernel/airplane/fuel.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/main.dart';
import 'package:scraplapl/ui/perfo/perfo_page.dart';

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
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: headersConso
                          .map((h) => TableRow(children: [
                                createCell(Center(
                                    child: Text(
                                  h,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ))),
                                ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(minWidth: 60),
                                    child: createCell(TextFormField(
                                        style: const TextStyle(fontSize: 12),
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
                                          } on FormatException {
                                            logger.w(
                                                "$value is not a valid consumption value");
                                          }
                                          setState(() {
                                            totalFuel = consoContent.values
                                                .reduce((a, b) => (a + b));
                                          });
                                        })))
                              ]))
                          .toList() +
                      [
                        TableRow(children: [
                          createCell(const Center(
                              child: Text(
                            "TOTAL",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))),
                          createCell(Text(
                            totalFuel.toString(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ))
                        ])
                      ]),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 0),
                  child: ElevatedButton(
                      onPressed: () {
                        if (depArpt != "" && arrArpt != "") {
                          createConsoPDF([depArpt, arrArpt]);
                        }
                      },
                      child: const Text(
                        "Valider",
                        style: TextStyle(fontSize: 16),
                      )))
            ],
          ),
        )));
  }
}
