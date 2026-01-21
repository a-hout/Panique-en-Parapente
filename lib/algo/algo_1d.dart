import 'dart:math';
import 'package:panique_en_parapente/service_elevation/elevation_data.dart';
import 'package:panique_en_parapente/service_elevation/elevation_factory.dart';
import 'package:panique_en_parapente/gps/gps_position.dart';

class Algo1D {
  ///gps position of waypoint
  final GpsPosition waypointPos;

  ///gps position of user
  final GpsPosition userPos;

  ///resolution of a tile
  final double maillage;

  ///path to tiles
  final String tilePath;

  ///fineness, about 9 or 10 normally for parapente
  final int f;

  ///for now, it's either swisstopo or the simulation
  final ElevationProvider provider;

  Algo1D({
    required this.waypointPos,
    required this.userPos,
    required this.maillage,
    required this.tilePath,
    required this.f,
    required this.provider,
  });

  ///algorithm method without taking into account the elevation data
  ///returns a double
  ///we draw a linear function between the user and the waypoint's position
  ///we check if the point at waypoint is lower than the waypoint
  ///if it is, return delta the user must climb
  double runNoObstacle() {
    return -(1 / f) * getHaversineDistance() +
        userPos.altitude -
        waypointPos.altitude;
  }

  ///algorithm method with elevation data consideration
  ///returns two doubles, the climb needed and the altitude at waypoint
  ///async because of _fetchTile
  Future<(double climbDelta, double altitudeWaypoint)> runWithObstacle(
    Map<String, ElevationData> tileMap,
    ElevationData? testTile,
  ) async {
    // U**********W   each star is a point that tests the elevation at that point
    // we divide the distance into n points and iterate over each distance from user to waypoint
    final distance = getHaversineDistance();
    final numPoints = (distance / maillage)
        .floor(); //number of points used to test the algorithm
    double maxClimbNeeded = double
        .negativeInfinity; //we want to get the lowest possible altitude difference (either positive or negative)
    double finalAltitude = 0; //altitude relative to elevation at waypoint
    for (int i = 1; i <= numPoints; i++) {
      final t = i / numPoints;

      ///position at point t relative to user and waypoint position
      final lat = userPos.lat + (waypointPos.lat - userPos.lat) * t;
      final lon = userPos.lon + (waypointPos.lon - userPos.lon) * t;

      ///altitude at point t
      final distanceTraveled =
          distance * t; //t is between a very small fractional number and 1
      final glideAltitude = userPos.altitude - (distanceTraveled / f);

      final currentPoint = GpsPosition(
        lat: lat,
        lon: lon,
        altitude: glideAltitude,
      );

      final lookupGrid =
          "${currentPoint.getLV95()[1]}-${currentPoint.getLV95()[0]}";
      final tile =
          testTile ??
          tileMap[lookupGrid]; //get tile where the point is located, test tile is loaded when passed in argument (for unit test)
      if (tile == null) {
        throw Exception('Tile not loaded: $lookupGrid'); //shouldnt happen
      }

      final terrainElevation = tile.getElevationGPS(
        lat,
        lon,
      ); //exact elevation at lat and lon of the point

      final delta = glideAltitude - terrainElevation;

      if (delta < 0) {
        maxClimbNeeded = max(
          maxClimbNeeded,
          -delta,
        ); //inverted sign because we want to return the height the user must climb, not how much he is missing
      }
      if (t == 1) {
        //at waypoint
        finalAltitude = delta;
      }
    }

    return (
      maxClimbNeeded == double.negativeInfinity ? 0.0 : maxClimbNeeded,
      finalAltitude + maxClimbNeeded,
    ); //if no climb needed, then just return 0, 0
  }

  ///get the distance between the user and the waypoint's position using the haversine formula
  ///returns a double
  double getHaversineDistance() {
    double degreeToRadians = pi / 180.0;
    double dx = (waypointPos.lon - userPos.lon) * degreeToRadians;
    double dy = (waypointPos.lat - userPos.lat) * degreeToRadians;
    double a =
        pow(sin(dy / 2), 2) +
        cos(userPos.lat * degreeToRadians) *
            cos(waypointPos.lat * degreeToRadians) *
            pow(sin(dx / 2), 2);
    const r = 6371000; //radius earth
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }
}
