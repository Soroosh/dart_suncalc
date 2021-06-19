library dart_suncalc;

import 'package:dart_suncalc/types.dart';
import 'package:dart_suncalc/src/moon_utils.dart';
import 'package:dart_suncalc/src/sun_utils.dart';

import 'src/constants.dart';

/// Sun and moon times
class SunCalc {
  /// add custom sun angles to calculate the time for
  static void addTime(double angle,
      {required String riseName, required String setName}) {
    solarEvents.add(SolarEvent(angle, riseName, setName));
  }

  /// calculates sun position for a given date and latitude/longitude
  static Position getSunPosition(DateTime date,
      {required double lat, required double lng}) {
    return getSunAzimuthAndAltitud(date, lat: lat, lng: lng);
  }

  /// calculates sun times for a given date, latitude/longitude, and, optionally,
  /// the observer height (in meters) relative to the horizon
  static SunTimes getTimes(DateTime date,
      {required double lat, required double lng, double height = 0.0}) {
    return getSunTimes(date, lat: lat, lng: lng, height: height);
  }

  /// calculates the moon position for a given date time and geo position
  static Position getMoonPosition(DateTime date,
      {required double lat, required double lng}) {
    return getMoonPositionInternal(date, lat: lat, lng: lng);
  }

  /// calculations for illumination parameters of the moon,
  /// based on http://idlastro.gsfc.nasa.gov/ftp/pro/astro/mphase.pro formulas and
  /// Chapter 48 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
  static Illumination getMoonIllumination(DateTime date) {
    return getIllumination(date);
  }

  /// calculates the moon rise and set times
  static MoonTimes getMoonTimes(DateTime date,
      {required double lat, required double lng, bool inUtc = true}) {
    return getMoonTimesInternal(date, lat: lat, lng: lng, inUtc: inUtc);
  }
}
