import 'package:flutter/material.dart';

class SupAip {
  String id;
  String fir;
  String description;
  DateTimeRange validity;
  String link;

  SupAip(this.id, this.fir, this.description, this.validity, this.link);

  bool isActive(DateTime instant) {
    return !validity.start.isAfter(instant) && !validity.end.isBefore(instant);
  }

  @override
  String toString() {
    return 'SupAip{name: $id, fir: $fir, description: $description, validity:${validity.toString()}, link: $link}';
  }
}
