// measure the time it takes to load tiles for a number (1, 5, 10, 25, 50, 100)
import 'dart:io';
import 'dart:math';
import 'package:panique_en_parapente/analysis/utils/save_to_csv.dart';
import 'package:panique_en_parapente/service_elevation/elevation_data.dart';
import 'package:panique_en_parapente/service_elevation/geotiff_loader.dart';

void main() async {
  final data = <List<dynamic>>[
    ['tile_count', 'load_time_ms', 'memory_mb'],
  ];

  const String tilesPath = 'data/temp/';
  final dir = Directory(tilesPath);

  //get available grids from the folder
  final List<String> availableGrids = (await dir.list().toList())
      .where((e) => e.path.endsWith('.tif'))
      .map((e) {
        final filename = e.uri.pathSegments.last;
        final parts = filename.split('-');
        return '${parts[0]}-${parts[1]}';
      })
      .toSet() //only get unique values
      .toList();

  if (availableGrids.isEmpty) {
    print("no tiles files found in $tilesPath");
    return;
  }

  final Stopwatch stopwatch = Stopwatch();

  // 2. Test with different counts
  for (int count in [1, 5, 10, 25, 50, 100]) {
    // if we don't have enough unique tiles, we might have to reuse some so we will shuffle to vary the load orde
    availableGrids.shuffle(Random());

    stopwatch.reset();
    stopwatch.start();

    final List<ElevationData> loadedTiles = [];

    for (int i = 0; i < count; i++) {
      //get grid ID (and go back around if overflow)
      final String gridId = availableGrids[i % availableGrids.length];

      try {
        final tile = await GeotiffLoader.loadGeoTiffByLV95(gridId, tilesPath);
        loadedTiles.add(tile);
      } catch (e) {
        print("error loading $gridId");
      }
    }

    stopwatch.stop();

    //we calcluate cumulative memory
    final int totalBytes = loadedTiles.fold(
      0,
      (sum, tile) => sum + tile.sizeBytes,
    );
    final double totalMB = totalBytes / (1024 * 1024);

    data.add([count, stopwatch.elapsedMilliseconds, totalMB]);
    print(
      'Count: $count | Time: ${stopwatch.elapsedMilliseconds}ms | Total Memory: ${totalMB.toStringAsFixed(2)}MB',
    );
  }

  SaveToCsv.save('data/processed/tile_load_analysis2.csv', data);
}
