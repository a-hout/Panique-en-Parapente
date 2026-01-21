import 'dart:typed_data';

import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'package:panique_en_parapente/service_elevation/elevation_data.dart';
import 'package:panique_en_parapente/service_elevation/service_elevation.dart';

class ElevationSim implements ServiceElevation {
  @override
  Future<ElevationData> fetchElevation(
    double lat,
    double lon,
    double radiusKm,
  ) async //async because Fture is an asynchronous type useful for fetching and getting
  {
    double areaSize = 3000.0; // for 9km^2 grid
    double resolution = 0.5; //simulate maillage of 0.5
    int gridSize = (areaSize / resolution).toInt();

    return generateFlatTerrain(lat, lon, gridSize, resolution);
  }

  ///simulated elevation data at 500m altitude
  static ElevationData generateFlatTerrain(
    double centerLat,
    double centerLon,
    int gridSize,
    double resolution,
  ) {
    final elevations = Float32List(gridSize * gridSize);
    for (int i = 0; i < elevations.length; i++) {
      elevations[i] = 500.0;
    }

    final bounds = _createBounds(centerLat, centerLon, gridSize, resolution);
    return ElevationData(
      elevations: elevations,
      rows: gridSize,
      cols: gridSize,
      resolution: resolution,
      bounds: bounds,
    );
  }

  ///generates a vertical ridge in the middle
  static ElevationData generateSingleRidge(
    double centerLat,
    double centerLon,
    int gridSize,
    double resolution, {
    double baseElevation = 500.0,
    double ridgeElevation = 1500.0,
  }) {
    final elevations = Float32List(gridSize * gridSize); //init the matrix

    //complete base elevation for the matrix
    for (int i = 0; i < elevations.length; i++) {
      elevations[i] = baseElevation;
    }

    //generate the rdige in center (10 meters wide)
    final ridgeWidthPixels = (10 / resolution).toInt();
    final centerRow =
        gridSize ~/ 2; //get int division to determine the approximate center

    for (int row = 0; row < gridSize; row++) {
      for (
        int dCol = -ridgeWidthPixels ~/ 2;
        dCol <= ridgeWidthPixels ~/ 2;
        dCol++
      ) {
        final col = centerRow + dCol;
        if (col >= 0 && col < gridSize) {
          elevations[row * gridSize + col] = ridgeElevation;
        }
      }
    }

    final bounds = _createBounds(centerLat, centerLon, gridSize, resolution);

    return ElevationData(
      elevations: elevations,
      rows: gridSize,
      cols: gridSize,
      resolution: resolution,
      bounds: bounds,
    );
  }

  ///generates a lot of ridges
  static ElevationData generateMultipleRidges(
    double centerLat,
    double centerLon,
    int gridSize,
    double resolution, {
    double baseElevation = 500.0,
  }) {
    final elevations = Float32List(gridSize * gridSize);

    for (int i = 0; i < elevations.length; i++) {
      elevations[i] = baseElevation;
    }

    final center = gridSize ~/ 2;

    //generate the different ridges
    _addVerticalRidge(elevations, gridSize, center - gridSize ~/ 4, 800.0);

    _addHorizontalRidge(elevations, gridSize, center, 1200.0);

    _addDiagonalRidge(elevations, gridSize, 600.0);

    /*
    should look a bit like this hopefully

    --------------------------
    |500  500  800  500  600 |
    |500  500  800  600  500 |
    |1200 1200 600 1200 1200|
    |500  600  800  500  500 |
    |600  500  800  500  500 |
    --------------------------
    */

    final bounds = _createBounds(centerLat, centerLon, gridSize, resolution);

    return ElevationData(
      elevations: elevations,
      rows: gridSize,
      cols: gridSize,
      resolution: resolution,
      bounds: bounds,
    );
  }

  static void _addDiagonalRidge(
    Float32List elevations,
    int gridSize,
    double height,
  ) {
    const ridgeWidth = 20;
    for (int row = 0; row < gridSize; row++) {
      final col = row; //for diagonal 45 degrees
      for (
        int d = -ridgeWidth ~/ 2;
        d <= ridgeWidth ~/ 2;
        d++
      ) // tilde slash will return the division in integer format
      {
        //here we go from the left part of half the diagonal width to the the right side, this is thus the width of the ridge
        final c = col + d;
        if (c >= 0 && c < gridSize) {
          final index = row * gridSize + c;
          elevations[index] = height;
        }
      }
    }
  }

  static void _addHorizontalRidge(
    Float32List elevations,
    int gridSize,
    int row,
    double height,
  ) {
    const ridgeWidth = 20;
    for (int col = 0; col < gridSize; col++) {
      for (int dr = -ridgeWidth ~/ 2; dr <= ridgeWidth ~/ 2; dr++) {
        final r = row + dr;
        if (r >= 0 && r < gridSize) {
          final index = r * gridSize + col;
          elevations[index] = height;
        }
      }
    }
  }

  static void _addVerticalRidge(
    Float32List elevations,
    int gridSize,
    int col,
    double height,
  ) {
    const ridgeWidth = 20;
    for (int row = 0; row < gridSize; row++) {
      for (int dc = -ridgeWidth ~/ 2; dc <= ridgeWidth ~/ 2; dc++) {
        final c = col + dc;
        if (c >= 0 && c < gridSize) {
          final index = row * gridSize + c;
          elevations[index] = height;
        }
      }
    }
  }

  ///elevation data needs a bounding box so we create a simulated one
  static BoundingBox _createBounds(
    double centerLat,
    double centerLon,
    int gridSize,
    double resolution,
  ) {
    const latPerM = 1 / 111320.0; //lat per meter approximate
    const lonPerM =
        1 / 78850.0; //approximate as well, it's a simulation after all

    final halfSizeM = (gridSize * resolution) / 2;
    final halfLatDeg =
        halfSizeM *
        latPerM; //get lat degrees difference aproximate frm gridsize and resolution
    final halfLonDeg = halfSizeM * lonPerM;

    return BoundingBox(
      centerLat - halfLatDeg,
      centerLat + halfLatDeg,
      centerLon - halfLonDeg,
      centerLon + halfLonDeg,
    );
  }
}
