import 'package:flutter/material.dart';

class SupAip {
  String id;
  String description;
  DateTimeRange validity;
  String link;

  SupAip(this.id, this.description, this.validity, this.link);

  bool isActive(DateTime instant) {
    return !this.validity.start.isAfter(instant) &&
        !this.validity.end.isBefore(instant);
  }

  @override
  String toString() {
    return 'SupAip{name: $id, description: $description, validity:${validity.toString()}, link: $link}';
  }
}
