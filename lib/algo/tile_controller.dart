import 'package:panique_en_parapente/service_elevation/elevation_data.dart';
import 'package:panique_en_parapente/service_elevation/geotiff_loader.dart';

class TileController {
  final Map<String, ElevationData> tilesInMemory =
      {}; //key is LV95 coordinate, value is the filename of the tile
  final String tileFolder;
  final int endX, endY; //waypoint LV95 grid in integer

  TileController({
    required this.tileFolder,
    required this.endX,
    required this.endY,
  });

  Future<void> run(int startX, int startY) async {
    final tilesInPath = bresenhamAlgorithm(startX, startY);
    final required = tilesInPath.map((p) => "${p[1]}-${p[0]}").toSet();

    tilesInMemory.removeWhere(
      (k, v) => !required.contains(k),
    ); //remove unused tiles

    //load missing tiles in parallel, IO tile laoding is the biggest bottleneck so far in terms of performance
    final missing = required
        .where((t) => !tilesInMemory.containsKey(t))
        .toList();
    final futures = missing.map(
      (t) => GeotiffLoader.loadGeoTiffByLV95(t, tileFolder),
    );
    final loaded = await Future.wait(futures);

    for (int i = 0; i < missing.length; i++) {
      tilesInMemory[missing[i]] = loaded[i];
    }
  }

  ///returns the tiles which are between the user and the waypoint
  List<List<int>> bresenhamAlgorithm(int startX, int startY) {
    List<List<int>> tilesInPath = [];
    int dx = (endX - startX).abs();
    int dy = (endY - startY).abs();
    int sx = (startX < endX) ? 1 : -1;
    int sy = (startY < endY) ? 1 : -1;

    int x = startX;
    int y = startY;

    int error = dx - dy;

    while (true) {
      //margin of 1 tile around path
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          tilesInPath.add([x + i, y + j]);
        }
      }
      //tilesInPath.add([x, y]);
      if ((x == endX) && (y == endY)) {
        break; //can't do it in wihle, straight lines are a problem
      }

      int e2 =
          2 *
          error; //new variable, since we want to test two conditions and not modify the error while still needing to test the initial error

      ///X step
      if (e2 > -dy) {
        error -= dy;
        x += sx;
      }

      ///Y step
      if (e2 < dx) {
        error += dx;
        y += sy;
      }
    }

    //to set then back to list to prevent duplicates
    return tilesInPath.toSet().map((t) => t).toList();
  }
}
