import 'dart:math';

import 'package:panique_en_parapente/service_elevation/elevation_data.dart';
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

  Algo1D({
    required this.waypointPos,
    required this.userPos,
    required this.maillage,
    required this.tilePath,
  });

  double runNoObstacle()
  /*
  algorithm method without taking into account the elevation data
  returns a double
  */
  {
    //we draw a linear function between the user and the waypoint's position
    //we check if the point at waypoint is lower than the waypoint
    //if it is, return delta the user must climb + safety margin

    const f = 9; //fineness ratio for glide parapente
    const safetyMargin = 3; //3 meter safety margin ok?
    return -(1 / f) * getHaversineDistance() +
        userPos.altitude -
        waypointPos.altitude -
        safetyMargin;
  }

  double runWithObstacle()
  /*
  algorithm method with elevation data consideration
  returns a double
  */
  {
    // U**********W   each star is a point that tests the elevation at that point
    // we divide the distance into n points and iterate over each distance from user to waypoint

    double distance = getHaversineDistance();
    double maxUnsafeDelta = double
        .infinity; //we want to get the lowest possible altitude difference (either positive or negative)
    for (int i = 1; i < distance / maillage; i++)
    {
      double altitude = 0.0; // TODO actual elevation of the point!
      GpsPosition currentPoint = GpsPosition(lat: , lon: , altitude: altitude);

      ElevationData tile = _fetchTile(currentPoint);

      double delta = getPointTileDelta(currentPoint, tile) ;
      if (delta < maxUnsafeDelta)
      {
        maxUnsafeDelta = delta;
      }
    }

    //we draw a line between the user and the waypoint
    //we divide the line into gps points so that they are about 0.5m equidistant
    //for each point, we check if the elevation data of that tile at the point's position is lower than the altitude of the point
    //we keep maxDelta in memory and return it to indicate how much the user must climb
    return maxUnsafeDelta;
  }

  double getHaversineDistance()
  /*
  Get the distance between the user and the waypoint's position using the haversine formula
  Returns a double
  */
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

  Future<ElevationData> _fetchTile(GpsPosition pos) async {
    final dir = Directory(tilePath);
    final List<FileSystemEntity> entities = await dir.list().toList();
    for (int i = 0; i < entities.length; i++) {
      final boundsName =
          path.basenameWithoutExtension(entities[i].path).split('-')
              as List<double>;

      final bounds = BoundingBox(
        boundsName[0],
        boundsName[1],
        boundsName[2],
        boundsName[3],
      );
      if (pos.lat > bounds.minLat &&
          pos.lat < bounds.maxLat &&
          pos.lon > bounds.minLon &&
          pos.lon < bounds.maxLon) {
        File file = File(entities[i].path);
        ElevationData tile = GeotiffLoader.loadGeoTiff(file, bounds);
      }
      //if no tile, then what? download file from api? takes time and this should be fast
    }
    return await tile;
  }

  double getPointTileDelta(GpsPosition point, ElevationData tile)
  /*
  get the difference in altitude between an algorithmic point and the tile it's in
  */
  {
    return point.altitude - tile.getElevationGPS(point.lat, point.lon);
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
