// for r = 1, 5, 15, 25
// plot the time it takes to download all tiles
// max tiles = (2r+1)^2
// min tiles = 2r^2
import 'dart:io';
import 'package:panique_en_parapente/analysis/utils/save_to_csv.dart';
import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'package:panique_en_parapente/service_elevation/swisstopo_tile_downloader.dart';

Future<void> main(List<String> args) async {
  final radius = [1.0, 5.0, 15.0, 25.0];
  final elapsedTime = [];
  final numberTiles = [];
  final stopwatch = Stopwatch();

  final currentDir = Directory.current.path;
  print("Starting download time analysis...");
  for (var r in radius) {
    final BoundingBox bbox = SwisstopoTileDownloader.calculateBbox(
      46.685213,
      7.853294,
      r,
    ); //centered in interlaken to be sure that maximum nb of tiles are fetched

    print("\ndownload time for r = $r");

    stopwatch.reset();
    stopwatch.start();

    final downloader = SwisstopoTileDownloader();
    final metadata = await downloader.fetchTileUrls(
      bbox.minLon,
      bbox.minLat,
      bbox.maxLon,
      bbox.maxLat,
    );

    numberTiles.add(metadata.length); //store number of tiles

    await downloader.downloadTiles(metadata, "$currentDir/data/temp/");

    elapsedTime.add(stopwatch.elapsed);
    print("elapsed time: ${elapsedTime.last}\n");
  }
  final data = [
    ['radius_km', 'elapsed_ms', 'num_tiles', 'network_mbps'],
  ];

  for (int i = 0; i < radius.length; i++) {
    data.add([
      radius[i].toString(),
      elapsedTime[i].inMilliseconds.toString(),
      numberTiles[i].toString(),
      (numberTiles[i] * 16.0 / elapsedTime[i].inSeconds).toStringAsFixed(2),
    ]);
  }
  SaveToCsv.save("$currentDir/data/processed/download_time.csv", data);
}
