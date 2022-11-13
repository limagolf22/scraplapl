// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:io';
import 'package:requests/requests.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:scraplapl/fuel_page.dart';
import 'package:scraplapl/tools.dart';

import 'perfo_page.dart';

const fuelConso = 25;

getPdfWeather(dep, arr, int fl) async {
  //FlutterSession session = FlutterSession();
  // HttpSession session = HttpSession();
  String loginURL = 'https://aviation.meteo.fr/ajax/login_valid.php';
  String getURL =
      "https://aviation.meteo.fr/recents_add.php?depart=$dep&arrivee=$arr&etapes=&fly_level=${fl.toString()}&domaine=FRANCE&tcatcag=&vaavag=";
  var s = await Requests.post(loginURL, body: {
    "login": "guigoliam",
    "password": "abe8ae729f800bf87f2ee0623d0d6dc8"
  });
  s.raiseForStatus();

  var r = await Requests.get(getURL);
  if (r.content() != "ko") {
    print("MTO pdf captured");
    String pdfURL =
        "https://aviation.meteo.fr/dossier_personnalise_show_pdf.php?id_recent_ordre=1&id=${r.content()}&origine=recents";
    var pdfRes = await Requests.get(pdfURL);
    var dir = await AppUtil.createFolderInAppDocDir('pdfs');
    File file = File("${dir}/MTO_$dep-$arr.pdf");
    await file.writeAsBytes(pdfRes.bodyBytes);
    // pdfRes.bodyBytes
    // pdfFile = open("MTO_"+dep+"-"+arr+".pdf", 'wb')
    // pdfFile.write(pdfRes.content)
    // pdfFile.close()
  } else {
    print("MTO pdf failed to be captures");
  }
}

Future<String> getPdfNotam(
    List<String> arpts, String date, String heure) async {
  // var response = await Requests.get(
  //   'http://notamweb.aviation-civile.gouv.fr/Script/IHM/Com_ChargementRessource.php',
  // );
  // print(response.headers.keys);
  // print(response.headers.values);

  // Requests.addCookie('http://notamweb.aviation-civile.gouv.fr', "PHPSESSID",
  //     "3383127834f30744303e861911fbca64");

  // var a = await Requests.getStoredCookies(
  //     'http://notamweb.aviation-civile.gouv.fr');
  // for (var element in a.values) {
  //   print(element.value);
  // }

  var map = new Map<String, String>();

  map['bResultat'] = "true";
  map["bImpression"] = "";
  // map['ModeAffichage'] = "RESUME";
  map["AERO_Date_DATE"] = date;
  map["AERO_Date_HEURE"] = heure;
  map["AERO_Langue"] = "FR";
  map["AERO_Duree"] = "12";
  map["AERO_CM_REGLE"] = "1";
  map["AERO_CM_GPS"] = "2";
  map["AERO_CM_INFO_COMP"] = "1";
  map["AERO_Rayon"] = "10";
  map["AERO_Plafond"] = "30";

  for (var i = 0; i < 12; i++) {
    if (i < arpts.length) {
      map["AERO_Tab_Aero[$i]"] = arpts[i];
    } else {
      map["AERO_Tab_Aero[$i]"] = "";
    }
  }

  map['bResultat'] = "true";
  map["bImpression"] = "1";
  map["bResaisir"] = "true";
  map["AERO_Date_DATE"] = date;
  map["AERO_Date_HEURE"] = heure;
  map["AERO_Langue"] = "FR";
  map["AERO_Duree"] = "12";
  map["AERO_CM_REGLE"] = "1";
  map["AERO_CM_GPS"] = "2";
  map["AERO_CM_INFO_COMP"] = "1";
  map["AERO_Rayon"] = "10";
  map["AERO_Plafond"] = "30";

  for (var i = 1; i < 101; i++) {
    map["NOTAM[$i]"] = "on";
  }

  // var sessionOpener =
  //     await Requests.post('http://notamweb.aviation-civile.gouv.fr',
  //         body: map,
  //         queryParameters: {"AERO_Langue": "FR"},
  //         headers: {
  //           "Connection": "keep-alive",
  //           "Accept": "*/*",
  //           "Content-type": "application/x-www-form-urlencoded ",
  //           "Accept-Encoding": "gzip, deflate"
  //         },
  //         verify: false);
  var resinit = await http.get(Uri.parse(
      'https://notamweb.aviation-civile.gouv.fr/Script/IHM/Bul_Aerodrome.php?AERO_Langue=FR'));
  http.Request request = http.Request(
      'POST',
      Uri.parse(
          'https://notamweb.aviation-civile.gouv.fr/Script/IHM/Bul_Aerodrome.php?AERO_Langue=FR'));
  request.bodyFields = map; // map;
  var myCookie = resinit.headers['set-cookie']!;
  request.headers['Cookie'] = myCookie.split(';')[0];
  request.headers['content-type'] = 'application/x-www-form-urlencoded';
  request.headers['accept'] = '*/*';
  request.headers['Accept-Encoding'] = "gzip, deflate";
  request.headers["Connection"] = "keep-alive";
  final resp = await request.send();

  final respStr = await resp.stream.bytesToString();

  //response1.raiseForStatus();

  // final http.Response response = await http.post(
  //   Uri.parse(0
  //       'http://notamweb.aviation-civile.gouv.fr/Script/IHM/Bul_Aerodrome.php?AERO_Langue=FR'),
  //   headers: <String, String>{
  //     "Connection": "keep-alive",
  //     "Accept": "*/*",
  //     "Content-Type": "application/x-www-form-urlencoded",
  //     "Accept-Encoding": "gzip, deflate"
  //   },
  //   body: map,
  // );

  // response1.raiseForStatus();
  String pdfId = findBetween(respStr, "../../", ".pdf");
  if (pdfId != "") {
    print("NOTAM pdf captured");
    await saveNotamFile(pdfId, arpts);
  } else {
    print("failed to get pdf for Notam");
  }
  return pdfId;
  //print(findBetween(response1.content(), "../../", ".pdf"));
}

saveNotamFile(String pdfId, List<String> arpts) async {
  String pdfURL = "https://notamweb.aviation-civile.gouv.fr/$pdfId.pdf";
  var pdfRes = await Requests.get(pdfURL);
  var dir = await AppUtil.createFolderInAppDocDir('pdfs');
  File file = File("$dir/Notam_${arpts[0]}-${arpts[1]}.pdf");
  await file.writeAsBytes(pdfRes.bodyBytes);
}

findBetween(String str, String before, String after) {
  var re = RegExp('(?<=$before)(.*)(?=$after)');
  var match = re.firstMatch(str);
  if (match != null) {
    return match.group(0);
  } else {
    return "";
  }
}

createPerfoPDF(List<String> arpts) async {
  final pdf = pw.Document();

  pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(children: [
          pw.Table(
              children: [0, 1, 2, 3, 4].map((row) {
                if (row == 0) {
                  return pw.TableRow(
                    children: headersPerfo.asMap().entries.map((col) {
                          return addPadding(pw.Text(
                            col.value,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                background: pw.BoxDecoration(
                                    color: getBackColor(col.key))),
                          ));
                        }).toList() +
                        [
                          addPadding(pw.Text(
                            "check",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ))
                        ],
                  );
                } else {
                  return pw.TableRow(
                      children: headersPerfo.asMap().entries.map((col) {
                            return addPadding(pw.Text(
                                perfoContent[row - 1][col.key],
                                textAlign: pw.TextAlign.center,
                                maxLines: 1,
                                style: pw.TextStyle(
                                    background: pw.BoxDecoration(
                                        color: getBackColor(col.key)))));
                          }).toList() +
                          [addPadding(pw.Text('V'))]);
                }
              }).toList(),
              border: (pw.TableBorder.all())),
          addPadding(pw.Image(pw.MemoryImage(
            File('assets/images/perfoTab.png').readAsBytesSync(),
          )))
        ]);
        // Center
      })); // Page
  var dir = await AppUtil.createFolderInAppDocDir('pdfs');
  final file = File("$dir/Perfo_${arpts[0]}-${arpts[1]}.pdf");
  await file.writeAsBytes(await pdf.save());
}

pw.Widget addPadding(pw.Widget el) {
  return pw.Padding(padding: const pw.EdgeInsets.all(4.0), child: el);
}

PdfColor getBackColor(int col) {
  switch (col) {
    case 5:
      return PdfColors.blue100;
    case 6:
      return PdfColors.cyan100;
    case 7:
      return PdfColors.green100;
    case 8:
      return PdfColors.lightGreen100;
    default:
      return PdfColors.white;
  }
}

createConsoPDF(List<String> arpts) async {
  final pdf = pw.Document();

  pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(children: [
          pw.Table(
              border: pw.TableBorder.all(),
              children: headersConso
                      .map((h) => pw.TableRow(children: [
                            addPadding(pw.Text(
                              h,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            )),
                            addPadding(pw.Text(
                              consoContent[h].toString(),
                              maxLines: 1,
                              style: pw.TextStyle(fontSize: 10),
                            ))
                          ]))
                      .toList() +
                  [
                    pw.TableRow(children: [
                      addPadding(pw.Text(
                        "total",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      )),
                      addPadding(pw.Text(
                          "${consoContent.values.reduce((a, b) => (a + b)).toString()} min\n${((consoContent.values.reduce((a, b) => (a + b)) * fuelConso / 60).floor() + 1).toString()} L",
                          textAlign: pw.TextAlign.center,
                          maxLines: 2,
                          style: const pw.TextStyle(
                              fontSize: 10,
                              background:
                                  pw.BoxDecoration(color: PdfColors.yellow))))
                    ])
                  ]),
        ]);
        // Center
      })); // Page
  var dir = await AppUtil.createFolderInAppDocDir('pdfs');
  final file = File("$dir/Conso_${arpts[0]}-${arpts[1]}.pdf");
  await file.writeAsBytes(await pdf.save());
}
