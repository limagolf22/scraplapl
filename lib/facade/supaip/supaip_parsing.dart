import 'package:html/dom.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:scraplapl/kernel/supaip/supaip_model.dart';

List<SupAip> parseAllSupAip(List<Element> elements) {
  return elements.map((e) => parseSupAip(e)).toList();
}

SupAip parseSupAip(Element trElement) {
  trElement.querySelector('a.lien_sup_aip > b')!.text;
  return SupAip(
      trElement.querySelector('a.lien_sup_aip > b')!.text,
      trElement.querySelector('a.lien_sup_aip > span')!.text.trim(),
      parseValidity(trElement),
      trElement.querySelector('a.lien_sup_aip')!.attributes["href"]!);
}

DateTimeRange parseValidity(Element trElement) {
  var dates =
      trElement.querySelectorAll('td.td_date_ligne_document > div > strong');

  return DateTimeRange(
      start: DateTime.parse(dates[0].text), end: DateTime.parse(dates[1].text));
}

String adaptSupAipId(SupAip supaip) {
  return supaip.id.replaceAll('/', '_');
}
