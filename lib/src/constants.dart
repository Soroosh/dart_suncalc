import 'dart:math' as math;

const double PI = math.pi;
const double RAD = PI / 180.0;
const double E = RAD * 23.4397; // obliquity of the Earth

// date/time constants and conversions
const int HOURS_IN_MS = 1000 * 60 * 60;
const int dayMs = HOURS_IN_MS * 24;
const int J1970 = 2440588;
const int J2000 = 2451545;
const double J0 = 0.0009;

// calculations for sun times
final List<SolarEvent> solarEvents = [
  SolarEvent(-0.833, 'sunrise', 'sunset'),
  SolarEvent(-0.3, 'sunriseEnd', 'sunsetStart'),
  SolarEvent(-6.0, 'dawn', 'dusk'),
  SolarEvent(-12.0, 'nauticalDawn', 'nauticalDusk'),
  SolarEvent(-18.0, 'nightEnd', 'night'),
  SolarEvent(6.0, 'goldenHourEnd', 'goldenHour')
];

class SolarEvent {
  final double angle;
  final String riseName;
  final String setName;

  const SolarEvent(this.angle, this.riseName, this.setName);
}
