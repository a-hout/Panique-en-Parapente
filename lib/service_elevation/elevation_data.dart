import 'dart:typed_data';

import 'package:panique_en_parapente/service_elevation/bounding_box.dart';

class ElevationData 
{
  final Float32List elevations; //this type is more performant than the default dart lists
  final int rows;
  final int cols;
  final double resolution; //maillage, for example 0.5m so each meter will have 2 points for example
  final BoundingBox bounds;

  ElevationData({required this.elevations, required this.rows, required this.cols, required this.resolution, required this.bounds});

  double getElevation(int row, int col)
  /*
  Returns elevation data at a specified grid coordinate
  */
  {
    if (row < 0 || row >= rows || col < 0 || col >= cols)
    {
      throw RangeError("Out of bounds: ($row, $col)");
    }
    return elevations[row * cols + col];
  }

  double getElevationGPS(double lat, double lon)
  /*
  Returns elevation data based on GPS coordinates
  */
  {
    final rowF = (bounds.maxLat - lat) / bounds.height * rows;
    final colF = (lon - bounds.minLon) / bounds.width * cols;

    final row = rowF.floor(); //has to be in int for list index
    final col = colF.floor();

    if (row < 0 || row >= rows -1 || col < 0 || col >= cols - 1)
    {
      //have to get the nearest point if this situation occurs
      final r = row.clamp(0, rows -1); //clamp gets the nearest number in a certain range
      final c = col.clamp(0, cols -1);
      return getElevation(r, c);
    }

    //this section uses biliniear interpolarisation as seen in traitement d'images I
    //necessary because we want to interpolate a point if the GPS point is between actual points in the data from the provider
    final v = rowF - row;
    final u = colF-col;

    final e00 = getElevation(row, col);
    final e10 = getElevation(row + 1, col);
    final e01 = getElevation(row, col + 1);
    final e11 = getElevation(row + 1, col + 1);

    return (1 - v) * (1 - u) * e00 + //see slide 18 of pdf 3.1 traitement d'imge
        v * (1 - u) * e10 +
        (1 - v) * u * e01 +
        v * u * e11;
  }
}