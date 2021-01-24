import 'package:meta/meta.dart';

import './constants.dart';
import 'dart:math' as math;

num julianCycle({@required num d, @required num lw}) {
  assert(d != null);
  assert(lw != null);
  return (d - J0 - lw / (2 * PI)).round();
}

num approxTransit({@required num ht, @required num lw, @required num n}) {
  assert(ht != null);
  assert(lw != null);
  assert(n != null);
  return J0 + (ht + lw) / (2 * PI) + n;
}

num solarTransitJ({@required num ds, @required num M, @required num L}) {
  assert(ds != null);
  assert(M != null);
  assert(L != null);
  return J2000 + ds + 0.0053 * math.sin(M) - 0.0069 * math.sin(2 * L);
}

num hourAngle({@required num h, @required num phi, @required num d}) {
  assert(h != null);
  assert(phi != null);
  assert(d != null);
  return math.acos((math.sin(h) - math.sin(phi) * math.sin(d)) /
      (math.cos(phi) * math.cos(d)));
}

num getSetJ(
    {@required num h,
    @required num lw,
    @required num phi,
    @required num dec,
    @required num n,
    @required num M,
    @required num L}) {
  assert(h != null);
  assert(lw != null);
  assert(phi != null);
  assert(dec != null);
  assert(n != null);
  assert(M != null);
  assert(L != null);
  final w = hourAngle(h: h, phi: phi, d: dec);
  final a = approxTransit(ht: w, lw: lw, n: n);

  return solarTransitJ(ds: a, M: M, L: L);
}

DateTime hoursLater(DateTime date, num h) {
  final ms = h * 60 * 60 * 1000;
  return date.add(new Duration(milliseconds: ms.toInt()));
}
