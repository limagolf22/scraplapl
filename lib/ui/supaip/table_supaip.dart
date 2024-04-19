import 'package:flutter/material.dart';
import 'package:scraplapl/RequestStatus.dart';
import 'package:scraplapl/facade/supaip/scrapping_supaip.dart';
import 'package:scraplapl/facade/supaip/supaip_pdf.dart';
import 'package:scraplapl/kernel/supaip/supaip_model.dart';
import 'package:scraplapl/main.dart';
import 'package:url_launcher/url_launcher.dart';

List<SupAip> supAips = [];

class SupAipTable extends StatefulWidget {
  @override
  _SupAipTableState createState() => _SupAipTableState();
}

class _SupAipTableState extends State<SupAipTable> {
  RequestStatus supaipDownloadStatus = RequestStatus.UNDONE;

  Map<String, Map<String, bool>> checkboxValues =
      Map<String, Map<String, bool>>.fromIterable(FIRs,
          key: (fir) => fir,
          value: (fir) => Map<String, bool>.fromIterable(
              supAips.where((sa) => sa.fir == fir),
              key: (sa) => (sa as SupAip).id,
              value: (_) => false));

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
            children: FIRs.map((fir) => [
                      Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("|  $fir  |",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors.amber.shade200))),
                      Table(
                          columnWidths: {
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
                                            TableCellVerticalAlignment.middle,
                                        child: Material(
                                            child: Checkbox(
                                          value: checkboxValues[fir]![sa.id],
                                          onChanged: (newValue) {
                                            setState(() {
                                              checkboxValues[fir]![sa.id] =
                                                  newValue!;
                                            });
                                          },
                                        ))),
                                    TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                child: Text(
                                                  sa.id,
                                                  style: TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor:
                                                          Colors.blue.shade800,
                                                      decorationThickness: 2.0,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.blue.shade800),
                                                ),
                                                onTap: () => openURL(sa.link),
                                              )),
                                        )),
                                    TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: Text(sa.description,
                                              style: TextStyle(fontSize: 14)),
                                        )),
                                  ]),
                                ),
                              )
                              .toList())
                    ]).expand((element) => element).toList() +
                [
                  SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                      onPressed: retrievePdfPressed,
                      child: Text('Retrieve Pdfs'),
                    ),
                    iconRequestStatus(
                        supaipDownloadStatus, "Status of SupAip Pdfs downloads")
                  ])
                ],
          ),
        )));
  }

  void retrievePdfPressed() async {
    int res = await downloadSupAipPdfs(FIRs.map((fir) =>
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
