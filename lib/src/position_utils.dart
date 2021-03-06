import './constants.dart';
import 'dart:math' as math;

// general calculations for position
double rightAscension({required double l, required double b}) {
  return math.atan2(
      math.sin(l) * math.cos(E) - math.tan(b) * math.sin(E), math.cos(l));
}

double declination({required double l, required double b}) {
  return math.asin(
      math.sin(b) * math.cos(E) + math.cos(b) * math.sin(E) * math.sin(l));
}

double azimuth({required double h, required double phi, required double dec}) {
  return math.atan2(
      math.sin(h), math.cos(h) * math.sin(phi) - math.tan(dec) * math.cos(phi));
}

double altitude({required double h, required double phi, required double dec}) {
  return math.asin(math.sin(phi) * math.sin(dec) +
      math.cos(phi) * math.cos(dec) * math.cos(h));
}

double siderealTime({required double d, required double lw}) {
  return RAD * (280.16 + 360.9856235 * d) - lw;
}

double astroRefraction(double h1) {
  // the following formula works for positive altitudes only.
  // if h = -0.08901179 a div/0 would occur.
  final h = h1 < 0.0 ? 0.0 : h1;
  // formula 16.4 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
  // 1.02 / tan(h + 10.26 / (h + 5.10)) h in degrees, result in arc minutes -> converted to rad:
  return 0.0002967 / math.tan(h + 0.00312536 / (h + 0.08901179));
}
