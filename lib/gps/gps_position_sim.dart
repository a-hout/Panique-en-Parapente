import 'package:panique_en_parapente/gps/gps_position.dart';

class GpsPositionSim {
  static List<GpsPosition> flatTerrainPath()
  /* 
  Here we simulate a path that is too steep to get to the waypoint so the user would need to clumb
  */
  {
    return [
      GpsPosition(lat: 46.501, lon: 6.501, altitude: 1000), //every 9 meters, drop 1 meter
      GpsPosition(lat: 46.502, lon: 6.501, altitude: 950),
      GpsPosition(lat: 46.503, lon: 6.501, altitude: 900),
      GpsPosition(lat: 46.504, lon: 6.501, altitude: 850),
      GpsPosition(lat: 46.505, lon: 6.501, altitude: 800),
      GpsPosition(lat: 46.506, lon: 6.501, altitude: 750),
      GpsPosition(lat: 46.507, lon: 6.501, altitude: 700), //waypoint
    ];
  }

  static List<GpsPosition> generatePath(GpsPosition start, GpsPosition end, int nbPoints)
  /* 
  This method interpolates (simple method this time) between two gps positions for n amount of points
  */
  {
    
    final points = <GpsPosition>[];
    for (var i = 0; i < nbPoints; i++) {
      final t = i / (nbPoints - 1); //
      points.add(GpsPosition(lat: start.lat + (end.lat - start.lat) * t,
       lon: start.lon + (end.lon - start.lon) * t,
       altitude: start.altitude + (end.altitude - start.altitude) * t));
    }
    return points;
  }
}