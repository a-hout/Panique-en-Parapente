import 'package:flutter/material.dart';
import 'package:panique_en_parapente/service_elevation/elevation_data.dart';
import 'package:panique_en_parapente/service_elevation/geotiff_loader.dart';

class TileController {
  Map<String, ElevationData>
  tilesInMemory; //key is LV95 coordinate, value is the filename of the tile

  int endX, endY;

  TileController(): endX = 0, endY = 0,tilesInMemory = {};

  void run() {
    List<List<int>> tilesInPath = bresenhamAlgorithm();

    Set<String> tilesRequired = tilesInPath
        .map((p) => "${p[0]}_${p[1]}")
        .toSet();

    List<String> tilesToRemove = tilesInMemory.keys
        .where((tile) => !tilesRequired.contains(tile))
        .toList();

    List<String> tilesToAdd = tilesRequired
        .where((tile) => !tilesInMemory.containsKey(tile))
        .toList();

    for (var tile in tilesToRemove) {
      tilesInMemory.remove(tile);
    }
    for (var tile in tilesToAdd) //this operation could take time. async?
    {
      tilesInMemory[tile] = GeotiffLoader.loadGeoTiffByLV95(tile, )
    }
  }

  List<List<int>> bresenhamAlgorithm(int startX, int startY)
  ///returns the tiles which are between the user and the waypoint
  {
    List<List<int>> tilesInPath = [];
    int dx = (endX - startX).abs();
    int dy = (endY - startY).abs();
    int sx = (startX < endX) ? 1 : -1;
    int sy = (startY < endY) ? 1 : -1;

    int x = startX;
    int y = startY;

    int error = dx - dy;

    while (true) {
      tilesInPath.add([x, y]);
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

    return tilesInPath;
  }
}
