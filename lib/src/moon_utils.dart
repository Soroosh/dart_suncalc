import './constants.dart';
import './position_utils.dart';
import 'dart:math' as math;

// moon calculations, based on http://aa.quae.nl/en/reken/hemelpositie.html formulas
Map<String, num> moonCoords(num d) {
  final L = RAD * (218.316 + 13.176396 * d);
  final M = RAD * (134.963 + 13.064993 * d);
  final F = RAD * (93.272 + 13.229350 * d);

  final l = L + RAD * 6.289 * math.sin(M);
  final b = RAD * 5.128 * math.sin(F);
  final dt = 385001 - 20905 * math.cos(M);

  return {
    "ra": rightAscension(l: l, b: b),
    "dec": declination(l: l, b: b),
    "dist": dt
  };
}
