library suncalc;

import 'dart:math' as math;

import 'package:suncalc/src/date_utils.dart';
import 'package:suncalc/src/moon_utils.dart';
import 'package:suncalc/src/position_utils.dart';
import 'package:suncalc/src/sun_utils.dart';
import 'package:suncalc/src/time_utils.dart';

import 'src/constants.dart';

// calculations for sun times
final times = [
  [-0.833, 'sunrise', 'sunset'],
  [-0.3, 'sunriseEnd', 'sunsetStart'],
  [-6, 'dawn', 'dusk'],
  [-12, 'nauticalDawn', 'nauticalDusk'],
  [-18, 'nightEnd', 'night'],
  [6, 'goldenHourEnd', 'goldenHour']
];

class SunCalc {
  static void addTime(num angle, String riseName, String setName) {
    times.add([angle, riseName, setName]);
  }

  // calculates sun position for a given date and latitude/longitude
  static Map<String, num> getPosition(DateTime date, num lat, num lng) {
    final lw = RAD * -lng;
    final phi = RAD * lat;
    final d = toDays(date);

    final c = sunCoords(d);
    final H = siderealTime(d, lw) - c["ra"];

    return {
      "azimuth": azimuth(H, phi, c["dec"]),
      "altitude": altitude(H, phi, c["dec"])
    };
  }

  static Map<String, num> getSunPosition(DateTime date, num lat, num lng) {
    return SunCalc.getPosition(date, lat, lng);
  }

  static Map<String, DateTime> getTimes(DateTime date, num lat, num lng) {
    final lw = RAD * -lng;
    final phi = RAD * lat;

    final d = toDays(date);
    final n = julianCycle(d, lw);
    final ds = approxTransit(0, lw, n);

    final M = solarMeanAnomaly(ds);
    final L = eclipticLongitude(M);
    final dec = declination(L, 0);

    final jnoon = solarTransitJ(ds, M, L);
    var i, time, jset, jrise;

    final result = {
      "solarNoon": fromJulian(jnoon),
      "nadir": fromJulian(jnoon - 0.5)
    };

    for (i = 0; i < times.length; i += 1) {
      time = times[i];

      jset = getSetJ(time[0] * RAD, lw, phi, dec, n, M, L);
      jrise = jnoon - (jset - jnoon);

      result[time[1]] = fromJulian(jrise);
      result[time[2]] = fromJulian(jset);
    }

    return result;
  }

  static Map<String, num> getMoonPosition(DateTime date, num lat, num lng) {
    final lw = RAD * -lng;
    final phi = RAD * lat;
    final d = toDays(date);

    final c = moonCoords(d);
    final H = siderealTime(d, lw) - c["ra"];
    var h = altitude(H, phi, c["dec"]);
    // formula 14.1 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
    final pa = math.atan2(math.sin(H),
        math.tan(phi) * math.cos(c["dec"]) - math.sin(c["dec"]) * math.cos(H));

    h = h + astroRefraction(h); // altitude correction for refraction

    return {
      "azimuth": azimuth(H, phi, c["dec"]),
      "altitude": h,
      "distance": c["dist"],
      "parallacticAngle": pa
    };
  }

  static Map<String, num> getMoonIllumination(DateTime date) {
    final d = toDays(date);
    final s = sunCoords(d);
    final m = moonCoords(d);

    final sdist = 149598000; // distance from Earth to Sun in km

    final phi = math.acos(math.sin(s["dec"]) * math.sin(m["dec"]) +
        math.cos(s["dec"]) * math.cos(m["dec"]) * math.cos(s["ra"] - m["ra"]));
    final inc =
        math.atan2(sdist * math.sin(phi), m["dist"] - sdist * math.cos(phi));
    final angle = math.atan2(
        math.cos(s["dec"]) * math.sin(s["ra"] - m["ra"]),
        math.sin(s["dec"]) * math.cos(m["dec"]) -
            math.cos(s["dec"]) *
                math.sin(m["dec"]) *
                math.cos(s["ra"] - m["ra"]));

    return {
      "fraction": (1 + math.cos(inc)) / 2,
      "phase": 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / PI,
      "angle": angle
    };
  }

  static Map getMoonTimes(DateTime date, num lat, num lng,
      [bool inUtc = true]) {
    var t = new DateTime(date.year, date.month, date.day, 0, 0, 0);
    if (inUtc) {
      t = new DateTime.utc(date.year, date.month, date.day, 0, 0, 0);
    }
    const hc = 0.133 * RAD;
    var h0 = SunCalc.getMoonPosition(t, lat, lng)["altitude"] - hc;
    var h1 = 0.0;
    var h2 = 0.0;
    var rise = 0.0;
    var s = 0.0;
    var a = 0.0;
    var b = 0.0;
    var xe = 0.0;
    var ye = 0.0;
    var d = 0.0;
    var roots = 0.0;
    var x1 = 0.0;
    var x2 = 0.0;
    var dx = 0.0;

    // go in 2-hour chunks, each time seeing if a 3-point quadratic curve crosses zero (which means rise or set)
    for (var i = 1; i <= 24; i += 2) {
      h1 = SunCalc.getMoonPosition(hoursLater(t, i), lat, lng)["altitude"] - hc;
      h2 = SunCalc.getMoonPosition(hoursLater(t, i + 1), lat, lng)["altitude"] -
          hc;

      a = (h0 + h2) / 2 - h1;
      b = (h2 - h0) / 2;
      xe = -b / (2 * a);
      ye = (a * xe + b) * xe + h1;
      d = b * b - 4 * a * h1;
      roots = 0;

      if (d >= 0) {
        dx = math.sqrt(d) / (a.abs() * 2);
        x1 = xe - dx;
        x2 = xe + dx;
        if (x1.abs() <= 1) roots++;
        if (x2.abs() <= 1) roots++;
        if (x1 < -1) x1 = x2;
      }

      if (roots == 1) {
        if (h0 < 0)
          rise = i + x1;
        else
          s = i + x1;
      } else if (roots == 2) {
        rise = i + (ye < 0 ? x2 : x1);
        s = i + (ye < 0 ? x1 : x2);
      }

      if ((rise != 0) && (s != 0)) {
        break;
      }

      h0 = h2;
    }

    final result = {};
    result["alwaysUp"] = false;
    result["alwaysDown"] = false;

    if (rise != 0) {
      result["rise"] = hoursLater(t, rise);
    }
    if (s != 0) {
      result["set"] = hoursLater(t, s);
    }

    if ((rise == 0) && (s == 0)) {
      result[ye > 0 ? "alwaysUp" : "alwaysDown"] = true;
    }

    return result;
  }
}
