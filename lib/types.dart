/// Position of celestial objects
class Position {
  final double azimuth;
  final double altitude;
  final double? distance;
  final double? parallacticAngle;

  Position({
    required this.azimuth,
    required this.altitude,
    this.distance,
    this.parallacticAngle,
  });
}

/// Illumination of the moon
class Illumination {
  final double fraction;
  final double phase;
  final double angle;

  Illumination({
    required this.fraction,
    required this.phase,
    required this.angle,
  });
}

/// Moon rise and set times
class MoonTimes {
  final bool alwaysUp;
  final bool alwaysDown;
  final DateTime? riseDateTime;
  final DateTime? setDateTime;

  MoonTimes({
    required this.alwaysUp,
    required this.alwaysDown,
    this.riseDateTime,
    this.setDateTime,
  });
}

/// Times for different solar events like sunrise and sunset
class SunTimes {
  final DateTime? solarNoon;
  final DateTime? nadir;
  DateTime? sunrise;
  DateTime? sunset;
  DateTime? sunriseEnd;
  DateTime? sunsetStart;
  DateTime? dawn;
  DateTime? dusk;
  DateTime? nauticalDawn;
  DateTime? nauticalDusk;
  DateTime? nightEnd;
  DateTime? night;
  DateTime? goldenHourEnd;
  DateTime? goldenHour;
  Map<String, DateTime?> custom = {};

  SunTimes({this.solarNoon, this.nadir});
}
