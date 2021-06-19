import '../types.dart';
import './constants.dart';
import './position_utils.dart';
import 'dart:math' as math;

import 'date_utils.dart';
import 'sun_utils.dart';
import 'time_utils.dart';

// moon calculations, based on http://aa.quae.nl/en/reken/hemelpositie.html formulas
MoonCoord moonCoords(double d) {
  final l1 = RAD * (218.316 + 13.176396 * d);
  final m = RAD * (134.963 + 13.064993 * d);
  final f = RAD * (93.272 + 13.229350 * d);

  final l = l1 + RAD * 6.289 * math.sin(m);
  final b = RAD * 5.128 * math.sin(f);
  final dt = 385001.0 - 20905.0 * math.cos(m);

  return MoonCoord(
    ra: rightAscension(l: l, b: b),
    dec: declination(l: l, b: b),
    dist: dt,
  );
}

class MoonCoord {
  final double ra;
  final double dec;
  final double dist;

  MoonCoord({required this.ra, required this.dec, required this.dist});
}

Position getMoonPositionInternal(DateTime date,
    {required double lat, required double lng}) {
  final lw = RAD * -lng;
  final phi = RAD * lat;
  final d = toDays(date);

  final c = moonCoords(d);
  final h1 = siderealTime(d: d, lw: lw) - c.ra;
  final h2 = altitude(h: h1, phi: phi, dec: c.dec);
  // formula 14.1 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
  final pa = math.atan2(math.sin(h1),
      math.tan(phi) * math.cos(c.dec) - math.sin(c.dec) * math.cos(h1));

  final h = h2 + astroRefraction(h2); // altitude correction for refraction

  return Position(
      azimuth: azimuth(h: h1, phi: phi, dec: c.dec),
      altitude: h,
      distance: c.dist,
      parallacticAngle: pa);
}

Illumination getIllumination(DateTime date) {
  final d = toDays(date);
  final s = sunCoords(d);
  final m = moonCoords(d);

  final sDist = 149598000.0; // distance from Earth to Sun in km

  final phi = math.acos(math.sin(s.dec) * math.sin(m.dec) +
      math.cos(s.dec) * math.cos(m.dec) * math.cos(s.ra - m.ra));
  final inc = math.atan2(sDist * math.sin(phi), m.dist - sDist * math.cos(phi));
  final angle = math.atan2(
      math.cos(s.dec) * math.sin(s.ra - m.ra),
      math.sin(s.dec) * math.cos(m.dec) -
          math.cos(s.dec) * math.sin(m.dec) * math.cos(s.ra - m.ra));

  return Illumination(
      fraction: (1.0 + math.cos(inc)) / 2.0,
      phase: 0.5 + 0.5 * inc * (angle < 0.0 ? -1.0 : 1.0) / PI,
      angle: angle);
}

MoonTimes getMoonTimesInternal(DateTime date,
    {required double lat, required double lng, bool inUtc = true}) {
  final t = inUtc
      ? DateTime.utc(date.year, date.month, date.day, 0, 0, 0)
      : DateTime(date.year, date.month, date.day, 0, 0, 0);
  const hc = 0.133 * RAD;
  var h0 = getMoonPositionInternal(t, lat: lat, lng: lng).altitude - hc;
  var rise = 0.0;
  var s = 0.0;
  var ye = 0.0;

  // go in 2-hour chunks, each time seeing if a 3-point quadratic curve crosses zero (which means rise or set)
  for (var i = 1; i <= 24; i += 2) {
    var x1 = 0.0;
    var x2 = 0.0;
    var dx = 0.0;
    final h1 =
        getMoonPositionInternal(hoursLater(t, i.toDouble()), lat: lat, lng: lng)
                .altitude -
            hc;
    final h2 = getMoonPositionInternal(hoursLater(t, i + 1), lat: lat, lng: lng)
            .altitude -
        hc;

    final a = (h0 + h2) / 2.0 - h1;
    final b = (h2 - h0) / 2.0;
    final xe = -b / (2.0 * a);
    ye = (a * xe + b) * xe + h1;
    final d = b * b - 4 * a * h1;
    var roots = 0;

    if (d >= 0) {
      dx = math.sqrt(d) / (a.abs() * 2);
      x1 = xe - dx;
      x2 = xe + dx;
      if (x1.abs() <= 1) roots++;
      if (x2.abs() <= 1) roots++;
      if (x1 < -1) x1 = x2;
    }

    if (roots == 1) {
      if (h0 < 0.0) {
        rise = i + x1;
      } else {
        s = i + x1;
      }
    } else if (roots == 2) {
      rise = i + (ye < 0.0 ? x2 : x1);
      s = i + (ye < 0.0 ? x1 : x2);
    }

    if ((rise != 0) && (s != 0)) {
      break;
    }

    h0 = h2;
  }

  return MoonTimes(
    alwaysUp: rise == 0 && s == 0 ? ye > 0 : false,
    alwaysDown: rise == 0 && s == 0 ? ye <= 0 : false,
    riseDateTime: rise != 0 ? hoursLater(t, rise) : null,
    setDateTime: s != 0 ? hoursLater(t, s) : null,
  );
}
