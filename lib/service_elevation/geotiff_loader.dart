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

    /*
    for testing, another way to do the loading, it's slower
    if (elevationsImage == null) {
      throw Exception("this should never happen but finally rid of the errors");
    }

    final elevations = Float32List(
      elevationsImage.width * elevationsImage.height,
    );
    if (elevationsImage.data is img.ImageDataFloat32) {
      final rawFloats = (elevationsImage.data as img.ImageDataFloat32)
          .toUint8List()
          .buffer
          .asFloat32List();
      elevations.setAll(0, rawFloats);
    }
    */

    final matrix = ElevationData(
      elevations: elevations,
      rows: elevationsImage.height,
      cols: elevationsImage.width,
      resolution: 0.5,
      bounds: bounds,
    );
    return matrix;
  }

  static Future<ElevationData> loadGeoTiffByLV95(
    String grid,
    String tilesPath,
  ) async {
    //get file from lv95 grid
    final dir = Directory(tilesPath);
    final entities = await dir.list().toList();
    final fileEntity = entities.firstWhere(
      (e) => e.path.contains('$grid-') && e.path.endsWith('.tif'),
      orElse: () => throw Exception("Tile not found: $grid"),
    );

    //get bounds from file
    final parts = fileEntity.uri.pathSegments.last
        .replaceAll('.tif', '')
        .split('-');
    if (parts.length != 6) throw Exception("Bad filename: ${fileEntity.path}");

    final bounds = BoundingBox(
      double.parse(parts[2]),
      double.parse(parts[3]),
      double.parse(parts[4]),
      double.parse(parts[5]),
    );

    //asynchronously get matrix from image
    final bytes = await File(fileEntity.path).readAsBytes();
    final image = img.decodeTiff(bytes)!;
    final elevations = Float32List(image.height * image.width);

    for (int i = 0; i < image.height; i++) {
      for (int j = 0; j < image.width; j++) {
        elevations[i * image.width + j] = image.getPixel(j, i).r.toDouble();
      }
    }

    return ElevationData(
      elevations: elevations,
      rows: image.height,
      cols: image.width,
      resolution: 0.5,
      bounds: bounds,
    );
  }
}
