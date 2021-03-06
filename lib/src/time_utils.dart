import './constants.dart';
import 'dart:math' as math;

int julianCycle({required double d, required double lw}) {
  return (d - J0 - lw / (2.0 * PI)).round();
}

double approxTransit({required double ht, required double lw, required int n}) {
  return J0 + (ht + lw) / (2.0 * PI) + n;
}

double solarTransitJ(
    {required double ds, required double m, required double l}) {
  return J2000 + ds + 0.0053 * math.sin(m) - 0.0069 * math.sin(2 * l);
}

double hourAngle({required double h, required double phi, required double d}) {
  return math.acos((math.sin(h) - math.sin(phi) * math.sin(d)) /
      (math.cos(phi) * math.cos(d)));
}

double observerAngle(double height) {
  return -2.076 * math.sqrt(height) / 60.0;
}

double getSetJ(
    {required double h,
    required double lw,
    required double phi,
    required double dec,
    required int n,
    required double m,
    required double l}) {
  final w = hourAngle(h: h, phi: phi, d: dec);
  final a = approxTransit(ht: w, lw: lw, n: n);

  return solarTransitJ(ds: a, m: m, l: l);
}

DateTime hoursLater(DateTime date, double h) {
  final ms = h * HOURS_IN_MS;
  return date.add(new Duration(milliseconds: ms.toInt()));
}
