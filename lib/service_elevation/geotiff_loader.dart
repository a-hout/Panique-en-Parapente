import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'package:panique_en_parapente/service_elevation/elevation_data.dart';

class GeotiffLoader {
  static ElevationData loadGeoTiff(File file, BoundingBox bounds) {
    final bytes = file.readAsBytesSync();
    final elevationsImage = img.decodeTiff(
      bytes,
    ); //elevation needs to be the pixel data extracted from the tif imaeg
    final elevations = Float32List(
      elevationsImage!.height * elevationsImage.width,
    ); //normally this is 2000 * 2000s

    for (int i = 0; i < elevationsImage.height; i++) {
      for (int j = 0; j < elevationsImage.width; j++) {
        elevations[i * elevationsImage.width + j] = elevationsImage
            .getPixel(j, i)
            .r
            .toDouble(); //not sure which color should extract since it's greyscale
      }
    }

    final matrix = ElevationData(
      elevations: elevations,
      rows: elevationsImage.height,
      cols: elevationsImage.width,
      resolution: 0.5,
      bounds: bounds,
    );
    return matrix;
  }

  static ElevationData loadGeoTiffByLV95(String grid, String tilesPath) {
    final dir = Directory(tilesPath);
    final fileEntity = dir.listSync().firstWhere(
      (entity) => entity.path.contains(grid) && entity.path.endsWith('.tif'),
      orElse: () => throw Exception("Tile not found for grid: $grid"),
    );

    final File file = File(fileEntity.path);

    final regex = RegExp(r"(\d+\.\d+)");
    final matches = regex.allMatches(fileEntity.uri.pathSegments.last).toList();

    if (matches.length < 4) {
      throw Exception(
        "Filename does not contain enough coordinate data: ${file.path}",
      );
    }

    final bounds = BoundingBox(
      double.parse(matches[0].group(0)!), // MinLat
      double.parse(matches[1].group(0)!), // MaxLat
      double.parse(matches[2].group(0)!), // MinLon
      double.parse(matches[3].group(0)!), // MaxLon
    );

    return loadGeoTiff(file, bounds);
  }
}
