// plot the bresenham algorithm
import 'dart:io';

import 'package:panique_en_parapente/algo/tile_controller.dart';
import 'package:panique_en_parapente/analysis/utils/save_to_csv.dart';

void main(List<String> args) {
  final tileFolder = "${Directory.current.path}/data/processed/";
  final tileController = TileController(
    endX: 2561,
    endY: 1205,
    tileFolder:
        tileFolder, //doesn't actually do anything since we're only running the bresenham algo
  );
  print("running Bresenham algorithm...");
  final tiles = tileController.bresenhamAlgorithm(2563, 1208);
  print("finished running, saving to CSV...");
  final data = [
    ['x, y'],
  ];
  for (var tile in tiles) {
    data.add(["${tile[0]},${tile[1]}"]);
  }
  SaveToCsv.save('$tileFolder/bresenham_path_chaumont_hearc.csv', data);
  print("saved");
}
