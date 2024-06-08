import 'package:flutter/material.dart';
import 'package:scraplapl/kernel/store/stores.dart';
import 'package:scraplapl/ui/request_status.dart';
import 'package:scraplapl/facade/supaip/supaip_scrapping.dart';
import 'package:scraplapl/facade/supaip/supaip_pdf.dart';
import 'package:scraplapl/main.dart';
import 'package:url_launcher/url_launcher.dart';

class SupAipTable extends StatefulWidget {
  const SupAipTable({super.key});

  @override
  SupAipTableState createState() => SupAipTableState();
}

class SupAipTableState extends State<SupAipTable> {
  RequestStatus supaipDownloadStatus = RequestStatus.UNDONE;

  Map<String, Map<String, bool>> checkboxValues = {
    for (var fir in firs)
      fir: {for (var sa in supAips.where((sa) => sa.fir == fir)) (sa).id: false}
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sup Aip Page'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: firs
                    .map((fir) => [
                          Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text("|  $fir  |",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      backgroundColor: Colors.amber.shade200))),
                          Table(
                              columnWidths: const {
                                0: IntrinsicColumnWidth(),
                                1: IntrinsicColumnWidth(),
                                2: IntrinsicColumnWidth()
                              },
                              border: TableBorder.all(),
                              children: supAips
                                  .where((sa) => sa.fir == fir)
                                  .map(
                                    (sa) => TableRow(
                                      children: ([
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Material(
                                                child: Checkbox(
                                              value:
                                                  checkboxValues[fir]![sa.id],
                                              onChanged: (newValue) {
                                                setState(() {
                                                  checkboxValues[fir]![sa.id] =
                                                      newValue!;
                                                });
                                              },
                                            ))),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: MouseRegion(
                                                  cursor:
                                                      SystemMouseCursors.click,
                                                  child: GestureDetector(
                                                    child: Text(
                                                      sa.id,
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              Colors.blue
                                                                  .shade800,
                                                          decorationThickness:
                                                              2.0,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .blue.shade800),
                                                    ),
                                                    onTap: () =>
                                                        openURL(sa.link),
                                                  )),
                                            )),
                                        TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(sa.description,
                                                  style: const TextStyle(
                                                      fontSize: 14)),
                                            )),
                                      ]),
                                    ),
                                  )
                                  .toList())
                        ])
                    .expand((element) => element)
                    .toList() +
                [
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      onPressed: retrievePdfPressed,
                      child: const Text('Retrieve Pdfs'),
                    ),
                    iconRequestStatus(
                        supaipDownloadStatus, "Status of SupAip Pdfs downloads")
                  ])
                ],
          ),
        )));
  }

  void retrievePdfPressed() async {
    int res = await downloadSupAipPdfs(firs
        .map((fir) =>
            supAips.where((sa) => checkboxValues[fir]![sa.id] ?? false))
        .expand((el) => el)
        .toList());
    setState(() {
      supaipDownloadStatus =
          res > 0 ? RequestStatus.FAIL : RequestStatus.SUCCESS;
    });
  }
}

void openURL(String url) async {
  var uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
