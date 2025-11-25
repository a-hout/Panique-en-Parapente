import 'package:flutter/material.dart';
import 'package:panique_en_parapente/ui/waypoint_picker_screen.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized(); //geolocator doesnt work if it's not bound
  runApp(MaterialApp(home: WaypointPickerScreen()));
  /*
  final f = 10;
  final r = 1.0;
  final waypointPos = GpsPosition(
    lat: 47.014925,
    lon: 7.005801,
    altitude: 465.5,
  ); //field next to marin centre
  final userPos = await GpsPosition.fromDevice();
  final appDir = await getApplicationDocumentsDirectory();
  final tileFolder = '${appDir.path}/tiles/';
  final dir = Directory(tileFolder);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final controller = ProgramController(
    f: f,
    r: r,
    waypointPos: waypointPos,
    userPos: userPos,
    tileFolder: tileFolder,
  );

  print("Downloading tiles...");
  await controller.downloadTiles();
  print("Download complete!");

  controller.start();

  await Future.delayed(Duration(minutes: 5));
  controller.end();
  */
  /*
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
  */

  /*
  final downloader = SwisstopoTileDownloader();
  final bbox = SwisstopoTileDownloader.calculateBbox(47.047312, 6.953335, 6.0);
  final tiles = await downloader.fetchTileUrls(
    bbox.minLon,
    bbox.minLat,
    bbox.maxLon,
    bbox.maxLat,
  );

  final files = await downloader.downloadTiles(tiles, './test_tiles');
  */

  /*
  final userPos = GpsPosition(lat: 47.047312, lon: 6.953335, altitude: 770.3);
  final waypointPos = GpsPosition(
    lat: 47.014925,
    lon: 7.005801,
    altitude: 465.5,
  );
  final algo = Algo1D(
    waypointPos: waypointPos,
    userPos: userPos,
    f: 10,
    maillage: 0.5,
    provider: ElevationProvider.swisstopo,
    tilePath: './test_tiles',
  );
  final result = await algo.runWithObstacle();
  print('Climb needed: $result m');
  */
}
