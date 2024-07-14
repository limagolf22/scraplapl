import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:scraplapl/facade/supaip/supaip_scrapping.dart';
import 'package:scraplapl/facade/supaip/supaip_parsing.dart';
import 'package:scraplapl/kernel/supaip/supaip_model.dart';
import 'package:test/test.dart';

import '../../test_config.dart';

void main() {
  group('test SupAip parser', () {
    test('test Supaip parser function', () async {
      var htmlTrElement = parse('''
<!DOCTYPE html>
<html>
  <body>
    <table>
      <tr class="tr_ligne_document new-supaip">
        <td class="td_icone_liste_document">
          <img
            title="PDF Icon"
            src="https://www.sia.aviation-civile.gouv.fr/static/version1688651761/frontend/SIA/charte_2019/fr_FR/images/pdf_icon.png"
            alt="PDF Icon"
            width="30"
            height="30"
          />
        </td>
        <td class="td_lien_liste_document">
          <a
            target="_blank"
            class="lien_sup_aip"
            href="https://www.sia.aviation-civile.gouv.fr/documents/download/f/d/12550723/"
          >
            <b>073/2024</b>
            <span
              >Modification AIP France AD2 LFRK relative aux procédures RWY31 ILS LOC Y et Z
              <i class="fas fa-external-link-alt"></i
            ></span>
          </a>
        </td>
        <td class="td_date_ligne_document">
          <div>Valide du <strong>2024-05-16</strong> au <strong>2024-07-10</strong></div>

          <div class="state-selected">
            <span
              ><input
                type="checkbox"
                name="IFR"
                value="IFR"
                class="hidden-check"
                onclick="return false;"
                onkeydown="return false;"
                checked
              />
              <label>IFR</label>
            </span>
            <span
              ><input
                type="checkbox"
                name="VFR"
                value="VFR"
                class="hidden-check"
                onclick="return false;"
                onkeydown="return false;"
              />
              <label>VFR</label>
            </span>
            <span
              ><input
                type="checkbox"
                name="AIRAC"
                value="AIRAC"
                class="hidden-check"
                onclick="return false;"
                onkeydown="return false;"
                checked
              />
              <label>AIRAC</label>
            </span>
          </div>
        </td>
      </tr>
    </table>
  </body>
</html>
''');
      var oth = htmlTrElement.querySelectorAll('tr.tr_ligne_document')[0];
      expect(
          parseSupAip(oth, 'LFBB').toString(),
          equals(SupAip(
                  "073/2024",
                  'LFBB',
                  "Modification AIP France AD2 LFRK relative aux procédures RWY31 ILS LOC Y et Z",
                  DateTimeRange(
                      start: DateTime(2024, 05, 16),
                      end: DateTime(2024, 07, 10)),
                  "https://www.sia.aviation-civile.gouv.fr/documents/download/f/d/12550723/")
              .toString()));
    });
    test('test Supaip scrapper function', () async {
      var now = DateTime.now();
      expect(await scrapSupAips(now, "LFBB"), equals(0));
    }, skip: isServerUnavailable);
  });
}
