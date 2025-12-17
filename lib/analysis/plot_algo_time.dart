// measure the algorithm time to complete when the waypoint is at certain distances (1km, 5km, 10km, 25km)
// since there are flutter dependencies, better to run this file with flutter run -d windows -t lib\analysis\plot_algo_time.dart
import 'dart:io';
import 'package:panique_en_parapente/algo/algo1D.dart';
import 'package:panique_en_parapente/analysis/utils/save_to_csv.dart';
import 'package:panique_en_parapente/analysis/utils/tile_download_util.dart';
import 'package:panique_en_parapente/gps/gps_position.dart';
import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'package:panique_en_parapente/service_elevation/elevation_data.dart';
import 'package:panique_en_parapente/service_elevation/elevation_factory.dart';
import 'package:panique_en_parapente/service_elevation/geotiff_loader.dart';

Future<void> main(List<String> args) async {
  for (var index = 0; index < 5; index++) {
    //we will launch the algorithm five times
    final distances = [1, 5, 10, 25];
    final elapsedTime = [];
    final climbs = [];
    final stopwatch = Stopwatch();

    print("Starting algo time analysis...");
    for (var d in distances) {
      print("\nalgo time for distance = $d");

      final waypoint = await TileDownloadUtil.downloadNumber(
        d + 1,
      ); //+1 as a target 1km away means the scope is 2 tiles

      final algo1d = Algo1D(
        f: 9,
        maillage: 0.5,
        provider: ElevationProvider.swisstopo,
        tilePath: TileDownloadUtil.folder,
        userPos: GpsPosition(lat: 46.685213, lon: 7.853294, altitude: 563.3),
        waypointPos: waypoint,
      );

      //generate tile map for use for algorithm
      final tileMap = <String, ElevationData>{};
      final entities = await Directory(TileDownloadUtil.folder).list().toList();

      for (var entity in entities) {
        if (!entity.path.endsWith('.tif')) continue;

        final parts = entity.uri.pathSegments.last
            .replaceAll('.tif', '')
            .split('-');
        final key = '${parts[0]}-${parts[1]}';
        final bounds = BoundingBox(
          double.parse(parts[2]),
          double.parse(parts[3]),
          double.parse(parts[4]),
          double.parse(parts[5]),
        );

        tileMap[key] = GeotiffLoader.loadGeoTiff(File(entity.path), bounds);
      }
      print(tileMap.keys);
      print("lat ${waypoint.lat}, lon ${waypoint.lon}");
      stopwatch.reset();
      stopwatch.start();

      final climb = await algo1d.runWithObstacle(tileMap, null);

      elapsedTime.add(stopwatch.elapsed);
      climbs.add(climb);
      print("climb needed: $climb");
      print("elapsed time: ${elapsedTime.last}\n");
    }
    final data = [
      ['distance', 'elapsed_ms', 'climb needed'],
    ];

    for (int i = 0; i < distances.length; i++) {
      data.add([
        distances[i].toString(),
        elapsedTime[i].inMilliseconds.toString(),
        climbs[i].toString(),
      ]);
    }
    SaveToCsv.save(
      "lib/analysis/data/processed/algo_time_$index.csv",
      data,
    ); //have to use this path because have to use flutter and not dart since one of the dependencies uses a flutter package
  }
}
