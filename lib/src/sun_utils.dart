import '../types.dart';
import './constants.dart';
import './position_utils.dart';
import 'dart:math' as math;

import 'date_utils.dart';
import 'time_utils.dart';

// general sun calculations
double solarMeanAnomaly(double d) {
  return RAD * (357.5291 + 0.98560028 * d);
}

double equationOfCenter(double m) {
  final firstFactor = 1.9148 * math.sin(m);
  final secondFactor = 0.02 * math.sin(2.0 * m);
  final thirdFactor = 0.0003 * math.sin(3.0 * m);

  return RAD * (firstFactor + secondFactor + thirdFactor);
}

double eclipticLongitude(double m) {
  final c = equationOfCenter(m);
  final p = RAD * 102.9372; // perihelion of the Earth

  return m + c + p + PI;
}

Position getSunAzimuthAndAltitud(DateTime date,
    {required double lat, required double lng}) {
  final lw = RAD * -lng;
  final phi = RAD * lat;
  final d = toDays(date);

  final c = sunCoords(d);
  final h = siderealTime(d: d, lw: lw) - c.ra;

  return Position(
    azimuth: azimuth(h: h, phi: phi, dec: c.dec),
    altitude: altitude(h: h, phi: phi, dec: c.dec),
  );
}

SunCoord sunCoords(double d) {
  final m = solarMeanAnomaly(d);
  final l = eclipticLongitude(m);

  return SunCoord(
    dec: declination(l: l, b: 0.0),
    ra: rightAscension(l: l, b: 0.0),
  );
}

class SunCoord {
  final double dec;
  final double ra;

  SunCoord({required this.dec, required this.ra});
}

double getNoon(DateTime date, {required double lat, required double lng}) {
  final lw = RAD * -lng;
  final d = toDays(date);
  final n = julianCycle(d: d, lw: lw);
  final ds = approxTransit(ht: 0.0, lw: lw, n: n);
  final m = solarMeanAnomaly(ds);
  final l = eclipticLongitude(m);

  return solarTransitJ(ds: ds, m: m, l: l);
}

double getSetTimeInternal(DateTime date,
    {required double angle,
    required double lat,
    required double lng,
    double height = 0.0}) {
  final lw = RAD * -lng;
  final phi = RAD * lat;

  final dh = observerAngle(height);

  final d = toDays(date);
  final n = julianCycle(d: d, lw: lw);
  final ds = approxTransit(ht: 0.0, lw: lw, n: n);

  final m = solarMeanAnomaly(ds);
  final l = eclipticLongitude(m);
  final dec = declination(l: l, b: 0.0);
  final h0 = (angle + dh) * RAD;

  return getSetJ(h: h0, lw: lw, phi: phi, dec: dec, n: n, m: m, l: l);
}

SunTimes getSunTimes(DateTime date,
    {required double lat, required double lng, double height = 0.0}) {
  final jNoon = getNoon(date, lat: lat, lng: lng);
  final sunTimes =
      SunTimes(solarNoon: fromJulian(jNoon), nadir: fromJulian(jNoon - 0.5));

  for (final event in solarEvents) {
    final jSet = getSetTimeInternal(
      date,
      angle: event.angle,
      lat: lat,
      lng: lng,
      height: height,
    );
    final jRise = jNoon - (jSet - jNoon);

    switch (event.riseName) {
      case 'sunrise':
        sunTimes.sunrise = fromJulian(jRise);
        sunTimes.sunset = fromJulian(jSet);
        break;
      case 'sunriseEnd':
        sunTimes.sunriseEnd = fromJulian(jRise);
        sunTimes.sunsetStart = fromJulian(jSet);
        break;
      case 'dawn':
        sunTimes.dawn = fromJulian(jRise);
        sunTimes.dusk = fromJulian(jSet);
        break;
      case 'nauticalDawn':
        sunTimes.nauticalDawn = fromJulian(jRise);
        sunTimes.nauticalDusk = fromJulian(jSet);
        break;
      case 'nightEnd':
        sunTimes.nightEnd = fromJulian(jRise);
        sunTimes.night = fromJulian(jSet);
        break;
      case 'goldenHourEnd':
        sunTimes.goldenHourEnd = fromJulian(jRise);
        sunTimes.goldenHour = fromJulian(jSet);
        break;
      default:
        sunTimes.custom[event.riseName] = fromJulian(jRise);
        sunTimes.custom[event.setName] = fromJulian(jSet);
        break;
    }
  }

  return sunTimes;
}
