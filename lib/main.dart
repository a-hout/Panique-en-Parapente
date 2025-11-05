import 'package:panique_en_parapente/algo/algo1d.dart';
import 'package:panique_en_parapente/gps/gps_position.dart';

Future<void> main(List<String> args) async {
  final user = GpsPosition(
    lat: 46.93048164361448,
    lon: 6.724780335855535,
    altitude: 1464.0,
  ); //le soliat
  final waypoint = GpsPosition(
    lat: 46.936308,
    lon: 6.724942,
    altitude: 1128.9,
  ); //fontaine froide, at the bottom of creux du van
  Algo1D algo = Algo1D(waypointPos: waypoint, userPos: user);
  print(
    "User takes off from le Soliat and gets to the coordinates of fontaine froide. Difference in altitude: ${algo.runNoObstacle()}",
  );

  final GpsPosition user2 = GpsPosition(
    lat: 47.025980,
    lon: 6.958065,
    altitude: 1068.4,
  ); //chaumont funiculaire

  final GpsPosition waypoint2 = GpsPosition(
    lat: 46.998025,
    lon: 6.940251,
    altitude: 479.3,
  );
  Algo1D algo2 = Algo1D(waypointPos: waypoint2, userPos: user2);
  print(
    "Can the user go to school paragliding if he lives near Chaumont? Difference in altitude: ${algo2.runNoObstacle()}",
  );

  final GpsPosition waypoint3 = GpsPosition(
    lat: 46.977999,
    lon: 6.807965,
    altitude: 772.9, //rochefort
  );
  Algo1D algo3 = Algo1D(waypointPos: waypoint3, userPos: user);
  print(
    "Can the user reach Rochefort from Le Soliat? Difference in altitude: ${algo3.runNoObstacle()}",
  );
}
