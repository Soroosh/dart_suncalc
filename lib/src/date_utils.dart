import './constants.dart';

final julianEpoch = DateTime.utc(-4713, 11, 24, 12, 0, 0);

double toJulian(DateTime date) {
  return date.difference(julianEpoch).inSeconds / Duration.secondsPerDay;
}

DateTime? fromJulian(num j) {
  if (j.isNaN)
    return null;
  else
    return julianEpoch
        .add(Duration(milliseconds: (j * Duration.millisecondsPerDay).floor()));
}

double toDays(DateTime date) {
  return toJulian(date) - J2000;
}
