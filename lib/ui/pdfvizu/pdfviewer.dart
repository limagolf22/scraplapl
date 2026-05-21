import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scraplapl/facade/pdfvizu/pdf_retriever.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerScreen extends StatefulWidget {
  final String target;

  const PDFViewerScreen(this.target, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _PDFViewerScreenState();
  }
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  List<String> mergedFiles = [];
  String chosenFile = "";

  @override
  initState() {
    super.initState();
    retrieveMergedPdfs().then((value) {
      if (value != null) {
        setState(() {
          mergedFiles = value;
          chosenFile = mergedFiles.firstWhere((f) => f.contains(widget.target),
              orElse: () => mergedFiles.isNotEmpty ? mergedFiles.first : "");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer"), actions: [
        DropdownButton<String>(
          value: chosenFile,
          icon: const Icon(Icons.arrow_downward),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (String? value) {
            // This is called when the user selects an item.
            setState(() {
              chosenFile = value!;
            });
          },
          items: mergedFiles.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(simplifyPath(value)),
            );
          }).toList(),
        ),
      ]),
      body: chosenFile != ""
          ? SfPdfViewer.file(
              File(chosenFile), // Add your PDF file to the assets folder
            )
          : const Icon(Icons.warning_amber),
    );
  }
}

String simplifyPath(String path){
 if(path.contains("/")){
  return path.split("/").last;
 } 
 if(path.contains("\\")){
  return path.split("\\").last;
 }
 return path;
}