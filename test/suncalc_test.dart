import 'package:dart_suncalc/suncalc.dart';
import 'package:test/test.dart';

class Coord {
  final double lat;
  final double lng;

  Coord({required this.lat, required this.lng});
}

void main() {
  bool near(double val1, double val2, [double margin = 1E-15]) {
    return ((val1 - val2).abs() < margin);
  }

  final date = DateTime.utc(2013, 3, 5);
  const lat = 50.5;
  const lng = 30.5;

  test('Duration class exposes static const variables', () {
    expect(Duration.millisecondsPerDay, isA<int>());
    expect(Duration.microsecondsPerMillisecond, 1000);
  });

  test('getTimes returns sun phases in summer in Kiev', () {
    final date = DateTime.utc(2020, 6, 10);
    final times = SunCalc.getTimes(date, lat: lat, lng: lng);

    expect(times.sunrise?.toIso8601String().substring(0, 19),
        "2020-06-10T01:47:58");
    expect(times.sunset?.toIso8601String().substring(0, 19),
        "2020-06-10T18:09:48");
  });

  test('getTimes returns sun phases in summer in Stockholm', () {
    DateTime date = DateTime.utc(2020, 6, 9);
    final sthlm = Coord(lat: 59.33538407920466, lng: 18.03007918439074);
    // https://www.timeanddate.com/sun/sweden/stockholm?month=6&year=2020
    final times = SunCalc.getTimes(date, lat: sthlm.lat, lng: sthlm.lng);

    expect(times.sunrise?.toIso8601String().substring(0, 19),
        "2020-06-09T01:35:47");
    expect(times.sunset?.toIso8601String().substring(0, 19),
        "2020-06-09T20:01:23");
  });

  test('getTimes returns sun phases in summer in Kiruna (midnight sun)', () {
    DateTime date = DateTime.utc(2020, 7, 1);
    final kiruna = Coord(lat: 67.8537716, lng: 20.1163502);
    // https://www.timeanddate.com/sun/sweden/kiruna?month=7&year=2020
    final times = SunCalc.getTimes(date, lat: kiruna.lat, lng: kiruna.lng);

    expect(times.sunrise, null);
    expect(times.sunset, null);
  });

  test('getTimes returns sun phases in summer in Kiruna', () {
    DateTime date = DateTime.utc(2020, 7, 17);
    final kiruna = Coord(lat: 67.8537716, lng: 20.1163502);
    // https://www.timeanddate.com/sun/sweden/kiruna?month=7&year=2020
    final times = SunCalc.getTimes(date, lat: kiruna.lat, lng: kiruna.lng);

    expect(times.sunrise?.toIso8601String().substring(0, 19),
        "2020-07-16T23:17:03");
    expect(times.sunset?.toIso8601String().substring(0, 19),
        "2020-07-17T22:16:31");
  });

  test(
      'getPosition returns azimuth and altitude for the given time and location',
      () {
    final sunPos = SunCalc.getSunPosition(date, lat: lat, lng: lng);

    expect(near(sunPos.azimuth, -2.5003175907168385), true);
    expect(near(sunPos.altitude, -0.7000406838781611), true);
  });

  test('getTimes returns sun phases for the given date and location', () {
    final times = SunCalc.getTimes(date, lat: lat, lng: lng);
    expect((times.solarNoon?.toIso8601String().substring(0, 19)),
        '2013-03-05T10:10:57');
    expect((times.nadir?.toIso8601String().substring(0, 19)),
        '2013-03-04T22:10:57');
    expect((times.sunrise?.toIso8601String().substring(0, 19)),
        '2013-03-05T04:34:56');
    expect((times.sunset?.toIso8601String().substring(0, 19)),
        '2013-03-05T15:46:57');
    expect((times.sunriseEnd?.toIso8601String().substring(0, 19)),
        '2013-03-05T04:38:19');
    expect((times.sunsetStart?.toIso8601String().substring(0, 19)),
        '2013-03-05T15:43:34');
    expect((times.dawn?.toIso8601String().substring(0, 19)),
        '2013-03-05T04:02:17');
    expect((times.dusk?.toIso8601String().substring(0, 19)),
        '2013-03-05T16:19:36');
    expect((times.nauticalDawn?.toIso8601String().substring(0, 19)),
        '2013-03-05T03:24:31');
    expect((times.nauticalDusk?.toIso8601String().substring(0, 19)),
        '2013-03-05T16:57:22');
    expect((times.nightEnd?.toIso8601String().substring(0, 19)),
        '2013-03-05T02:46:17');
    expect((times.night?.toIso8601String().substring(0, 19)),
        '2013-03-05T17:35:36');
    expect((times.goldenHourEnd?.toIso8601String().substring(0, 19)),
        '2013-03-05T05:19:01');
    expect((times.goldenHour?.toIso8601String().substring(0, 19)),
        '2013-03-05T15:02:52');
  });

  test('getMoonPosition returns moon position data given time and location',
      () {
    final moonPos = SunCalc.getMoonPosition(date, lat: lat, lng: lng);

    expect(near(moonPos.azimuth, -0.9783999522438226), true);
    expect(near(moonPos.altitude, 0.014551482243892251), true);
    expect(near(moonPos.distance ?? 0, 364121.37256256194), true);
  });

  test(
      'getMoonIllumination returns fraction and angle of moon illuminated limb and phase',
      () {
    final moonIllum = SunCalc.getMoonIllumination(date);

    expect(near(moonIllum.fraction, 0.4848068202456373), true);
    expect(near(moonIllum.phase, 0.7548368838538762), true);
    expect(near(moonIllum.angle, 1.67329426785783465), true);
  });

  test('getMoonTimes returns moon rise and set times', () {
    final moonTimes = SunCalc.getMoonTimes(DateTime.utc(2013, 3, 4),
        lat: lat, lng: lng, inUtc: true);

    expect(moonTimes.riseDateTime?.toIso8601String().substring(0, 19),
        "2013-03-04T23:54:29");
    expect(moonTimes.setDateTime?.toIso8601String().substring(0, 19),
        "2013-03-04T07:47:58");
  });

  test('add time', () {
    SunCalc.addTime(0, riseName: 'z1', setName: 'z2');
    final times = SunCalc.getTimes(date, lat: lat, lng: lng);

    expect(
        times.custom['z1']?.isBefore(times.sunrise ?? DateTime(1970)), false);
    expect(times.custom['z1']?.isBefore(times.sunriseEnd ?? DateTime(1970)),
        false);
    expect(times.custom['z2']?.isBefore(times.sunset ?? DateTime(1970)), true);
    expect(times.custom['z2']?.isBefore(times.sunsetStart ?? DateTime(1970)),
        true);
  });
}
