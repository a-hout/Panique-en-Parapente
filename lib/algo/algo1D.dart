import 'dart:collection';
import 'dart:math';

import 'package:panique_en_parapente/service_elevation/elevation_data.dart';
import 'package:panique_en_parapente/service_elevation/elevation_factory.dart';
import 'package:panique_en_parapente/service_elevation/geotiff_loader.dart';
import 'package:path/path.dart' as path;
import 'package:panique_en_parapente/gps/gps_position.dart';
import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'dart:io';

class Algo1D {
  final GpsPosition waypointPos;
  GpsPosition userPos;
  final double maillage;
  final String tilePath;
  int f; //fineness, about 9 or 10 normally for parapente
  final ElevationProvider
  provider; //for now, it's either swisstopo or the simulation

  Algo1D({
    required this.waypointPos,
    required this.userPos,
    required this.maillage,
    required this.tilePath,
    required this.f,
    required this.provider,
  });

  double runNoObstacle()
  //algorithm method without taking into account the elevation data
  //returns a double
  //
  //we draw a linear function between the user and the waypoint's position
  //we check if the point at waypoint is lower than the waypoint
  //if it is, return delta the user must climb + safety margin
  {
    return -(1 / f) * getHaversineDistance() +
        userPos.altitude -
        waypointPos.altitude;
  }

  Future<double> runWithObstacle() async
  //algorithm method with elevation data consideration
  //returns a double
  //async because of _fetchTile
  {
    // U**********W   each star is a point that tests the elevation at that point
    // we divide the distance into n points and iterate over each distance from user to waypoint

    final distance = getHaversineDistance();
    final numPoints = (distance / maillage)
        .floor(); //number of points used to test the algorithm
    print("Num points: $numPoints");

    double maxClimbNeeded = double
        .negativeInfinity; //we want to get the lowest possible altitude difference (either positive or negative)
    for (
      int i = 1;
      i <= numPoints;
      i++
    ) //TODO change this to a compute Isolate funciton
    {
      final t = i / numPoints;
      print("t = $t\n");

      ///position at point t relative to user and waypoint position
      final lat = userPos.lat + (waypointPos.lat - userPos.lat) * t;
      final lon = userPos.lon + (waypointPos.lon - userPos.lon) * t;

      ///altitude at point t
      final distanceTraveled = distance * t;
      final glideAltitude = userPos.altitude - (distanceTraveled / f);

      final currentPoint = GpsPosition(
        lat: lat,
        lon: lon,
        altitude: glideAltitude,
      );

      final tile = await _fetchTile(
        currentPoint,
      ); //get tile where the point is located
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
    }
    return maxClimbNeeded == double.negativeInfinity
        ? 0.0
        : maxClimbNeeded; //if no climb needed, then just return 0
  }

  double getHaversineDistance()
  //Get the distance between the user and the waypoint's position using the haversine formula
  //Returns a double
  {
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

  Future<ElevationData> _fetchTile(GpsPosition pos) async
  //asynchronous fetching of the tile
  {
    switch (provider) {
      case ElevationProvider.swisstopo:
        final dir = Directory(tilePath);
        final entities = await dir.list().toList();
        for (int i = 0; i < entities.length; i++) {
          final boundsName = path
              .basenameWithoutExtension(entities[i].path)
              .split('-');

          final bounds = BoundingBox(
            double.parse(boundsName[0]),
            double.parse(boundsName[1]),
            double.parse(boundsName[2]),
            double.parse(boundsName[3]),
          );
          if (pos.lat >= bounds.minLat &&
              pos.lat <= bounds.maxLat &&
              pos.lon >= bounds.minLon &&
              pos.lon <= bounds.maxLon) {
            return GeotiffLoader.loadGeoTiff(File(entities[i].path), bounds);
          }
        }
        throw Exception(
          'No tile at ${pos.lat}, ${pos.lon}',
        ); //if no tile, then user has gone off-grid and is on his own, should return an empty tile

      case ElevationProvider.sim:
        break; //TODO return elevation data based on a few parameters
    }
    throw Exception("Invalid service provider: $provider");
  }

  Future<void> loadTilesInPath() async
  //Loads into memory all tiles between the user and the waypoint, since tiles are 1km^2, we can sample every km
  {
    
  }

  /*
  void plotAlgo(int dimension)
  /*
  Function to visualize algo's
  */
  {
    switch (dimension)
    {
      case 1:

      case 2:
        //plot elevation data


    }
  }
  */
}
