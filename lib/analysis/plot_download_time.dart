// for r = 1, 5, 15, 25
// plot the time it takes to download all tiles
// max tiles = (2r+1)^2
// min tiles = 2r^2
// max size = 18MB
// min size = 12MB
// min and max tile size, min and max tile numbers so 4 variants
import 'dart:io';
import 'package:panique_en_parapente/analysis/utils/save_to_csv.dart';
import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'package:panique_en_parapente/service_elevation/swisstopo_tile_downloader.dart';

Future<void> main(List<String> args) async {
  final radius = [1.0, 5.0, 15.0, 25.0];
  final sizeTiles = [12, 14, 16, 18]; // MB
  const bandwidth = 16.7; // in MB/s, averge swisscom 5G speed

  final currentDir = Directory.current.path;

  final data = [
    ['radius_km', 'tile_size_mb', 'num_tiles', 'time'],
  ];

  for (var r in radius) {
    final BoundingBox bbox = SwisstopoTileDownloader.calculateBbox(
      46.685213,
      7.853294,
      r,
    );

    final downloader = SwisstopoTileDownloader();
    final metadata = await downloader.fetchTileUrls(
      bbox.minLon,
      bbox.minLat,
      bbox.maxLon,
      bbox.maxLat,
    );

    final numTiles = metadata.length;

    for (var size in sizeTiles) {
      data.add([
        r.toString(),
        size.toString(),
        numTiles.toString(),
        (numTiles * size / bandwidth).toStringAsFixed(2),
      ]);
    }
  }

  SaveToCsv.save("$currentDir/data/processed/download_time.csv", data);
}
