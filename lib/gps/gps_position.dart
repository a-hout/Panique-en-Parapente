import 'package:geolocator/geolocator.dart';

class GpsPosition {
  double lat;
  double lon;
  double altitude; //above sea levell
  double heading; // in degrees, useful for algo2D

  GpsPosition({
    double? headingUser,
    required this.lat,
    required this.lon,
    required this.altitude,
  }) : heading = headingUser ?? 0.0; //only the user should have a heading

  Future<void> setActualPosition() async
  ///calls the GPS service of the device to get current position
  ///needs permission of user for the package to fetch current position on their device
  {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission denied');
      }
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );
    lat = pos.latitude;
    lon = pos.longitude;
    altitude = pos.altitude;
    heading = pos.heading;
  }
}
