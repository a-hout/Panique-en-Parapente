import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'package:panique_en_parapente/service_elevation/elevation_data.dart';

class GeotiffLoader {
  ElevationData loadGeoTiff(File file, BoundingBox bounds) {
    final bytes = file.readAsBytesSync();
    final elevationsImage = img.decodeTiff(bytes); //elevation needs to be the pixel data extracted from the tif imaeg
    final elevations = Float32List(elevationsImage!.height * elevationsImage.width); //normally this is 2000 * 2000s
    
    for (int i = 0; i < elevationsImage.height; i++) {
      for (int j = 0; j < elevationsImage.width; j++) {
        elevations[i*elevationsImage.width + j] = elevationsImage.getPixel(i, j).r.toDouble(); //not sure which color should extract since it's greyscale
      }
    }

    final matrix = ElevationData(elevations: elevations, rows: elevationsImage.height, cols: elevationsImage.width, resolution: 0.5, bounds: bounds);
    return matrix;
  }
}