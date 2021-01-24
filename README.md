# dart_suncalc

A library to calculate sun and moon position and different solar and lunar times.
This library is a refactoring of https://github.com/shanus/flutter_suncalc/.
Which is a port  from https://github.com/mourner/suncalc.
The fix from https://github.com/jhsware/flutter_suncalc is included.

This code is based on the original Javascript suncalc by Vladimir Agafonkin ("mourner").

## Usage Example

```dart
import 'package:dart_suncalc/dart_suncalc.dart';

var date = new DateTime();

// get today's sunlight times for London
var times = SunCalc.getTimes(date, lat: 51.5, lng: -0.1);

// format sunrise time from the Date object
var sunriseStr = times["sunrise"].toLocal();

// get position of the sun (azimuth and altitude) at today's sunrise
var sunrisePos = SunCalc.getPosition(times["sunrise"], lat: 51.5, lng: -0.1);

// get sunrise azimuth in degrees
var sunriseAzimuth = sunrisePos["azimuth"] * 180 / PI;
```
