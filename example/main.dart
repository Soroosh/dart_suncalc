import 'package:dart_suncalc/suncalc.dart';

main() {
  final suncalc = SunCalc.getTimes(DateTime.now(), lat: 53.6, lng: 10.0);
  print(suncalc.sunset?.toIso8601String());
}
