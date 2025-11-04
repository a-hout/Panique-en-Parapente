import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'package:panique_en_parapente/service_elevation/elevation_data.dart';

class GeotiffLoader {
  ElevationData loadGeoTiff(File file, BoundingBox bounds) {
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

  /*
  ElevationData loadMultipleGeoTiff(List<File> files) {
    // for each file, create bounds for large matrix (lowest latmin and lonmin, to highest latmax and lonmax)
    // then, for each file add the elevation data in the CORRECT order
    // at the end, create large matrix with corresponding elevation data, rows and columns, same resolution and large bounding box
    double minLat = double.infinity;
    double minLon = double.infinity;
    double maxLat = double.negativeInfinity;
    double maxLon = double.negativeInfinity;
    for (int i = 0; i < files.length; i++) {
      final boundsName =
          basenameWithoutExtension(files[i].path).split('-') as List<double>;

      final bounds = BoundingBox(
        boundsName[0],
        boundsName[1],
        boundsName[2],
        boundsName[3],
      );

      minLat = min(minLat, bounds.minLat);
      minLon = min(minLon, bounds.minLat);
      maxLat = max(maxLat, bounds.maxLat);
      maxLon = max(maxLon, bounds.maxLon);
    }

    int currentRow = 0;

    files.sort((a, b) => )

    return largeMatrix;
  }
  */
}
