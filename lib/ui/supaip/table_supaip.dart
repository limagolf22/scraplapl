import 'package:flutter/material.dart';
import 'package:scraplapl/facade/supaip/scrapping_supaip.dart';
import 'package:scraplapl/main.dart';

import '../../RequestStatus.dart';
import '../../kernel/supaip/supaip_model.dart';

List<SupAip> supAips = [];

class SupAipTable extends StatefulWidget {
  @override
  _SupAipTableState createState() => _SupAipTableState();
}

class _SupAipTableState extends State<SupAipTable> {
  RequestStatus supaipDownloadStatus = RequestStatus.UNDONE;

  Map<String, bool> checkboxValues = Map<String, bool>.fromIterable(supAips,
      key: (sa) => (sa as SupAip).id, value: (_) => false);

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
            children: [
              Table(
                columnWidths: {
                  0: IntrinsicColumnWidth(),
                  1: IntrinsicColumnWidth(),
                  2: IntrinsicColumnWidth()
                },
                border: TableBorder.all(),
                children: supAips
                    .map(
                      (sa) => TableRow(
                        children: [
                          TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Material(
                                  child: Checkbox(
                                value: checkboxValues[sa.id],
                                onChanged: (newValue) {
                                  setState(() {
                                    checkboxValues[sa.id] = newValue!;
                                  });
                                },
                              ))),
                          TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  sa.id,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              )),
                          TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(sa.description,
                                    style: TextStyle(fontSize: 14)),
                              )),
                        ],
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                ElevatedButton(
                  onPressed: () async {
                    int res = await downloadSupAipPdfs(supAips
                        .where((sa) => checkboxValues[sa.id] ?? false)
                        .toList());
                    setState(() {
                      supaipDownloadStatus =
                          res > 0 ? RequestStatus.FAIL : RequestStatus.SUCCESS;
                    });
                  },
                  child: Text('Retrieve Pdfs'),
                ),
                iconRequestStatus(
                    supaipDownloadStatus, "Status of SupAip Pdfs downloads")
              ])
            ],
          ),
        )));
  }
}
