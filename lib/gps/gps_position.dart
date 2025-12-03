import 'package:geolocator/geolocator.dart';
import 'package:lv95/lv95.dart';

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
    this.heading = 0.0,
  });

  ///round about way of calling a constructor for the user asynchronously since futures dont exist for constructors
  static Future<GpsPosition> fromDevice() async {
    final pos = GpsPosition(lat: 0, lon: 0, altitude: 0);
    await pos.setActualPosition();
    return pos;
  }

  ///calls the GPS service of the device to get current position
  ///needs permission of user for the package to fetch current position on their device
  Future<void> setActualPosition() async {
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
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    );
    lat = pos.latitude;
    lon = pos.longitude;
    altitude = pos.altitude;
    print(altitude);
    heading = pos.heading;
  }

  ///get the integer part of the lv95 coords
  List<int> getLV95() {
    final wgs84 = LatLng(lat, lon);
    final xy = LV95.fromWGS84(wgs84);
    final endX = (xy.x / 1000).floor();
    final endY = (xy.y / 1000).floor();

    return [endX, endY];
  }
}
