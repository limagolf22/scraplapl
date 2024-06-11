import 'dart:math';

import 'package:latlong2/latlong.dart';

/// Gives relative coordinates between (52°N 5°W) and (41°N 10°E).
Point<double> latLngToPixPoint(LatLng point, double width, double height) {
  return Point(
    (point.longitude + 5) * (width / 15),
    height - (point.latitude - 41) * (height / 11),
  );
}
