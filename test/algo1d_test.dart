import 'package:flutter_test/flutter_test.dart';
import 'package:panique_en_parapente/algo/algo1d.dart';
import 'package:panique_en_parapente/gps/gps_position.dart';
import 'package:panique_en_parapente/service_elevation/elevation_sim.dart';
import 'package:panique_en_parapente/service_elevation/elevation_factory.dart';

void main() {
  group('algo1D_tests', () {
    test('flat terrain, no climb needed', () async {
      final centerLat = 46.997484;
      final centerLon = 6.938608;
      final gridSize = 6000;
      final resolution = 0.5;

      final tile = ElevationSim.generateFlatTerrain(
        centerLat,
        centerLon,
        gridSize,
        resolution,
      );

      // user is  100m away, same altitude as terrain
      final userPos = GpsPosition(
        lat: centerLat - 0.0005,
        lon: centerLon,
        altitude: 500.0,
      );
      final waypointPos = GpsPosition(
        lat: centerLat + 0.0005,
        lon: centerLon,
        altitude: 500.0,
      );

      final algo = Algo1D(
        waypointPos: waypointPos,
        userPos: userPos,
        maillage: 0.5,
        tilePath: '',
        f: 9,
        provider: ElevationProvider.sim,
      );

      final climbNeeded = await algo.runWithObstacle({}, tile);

      expect(climbNeeded, moreOrLessEquals(12.0, epsilon: 1.5)); //100/9
    });

    test('single ridge, high wall, precision test', () async {
      final centerLat = 46.997484;
      final centerLon = 6.938608;
      final gridSize = 6000;
      final resolution = 0.5;

      final tile = ElevationSim.generateSingleRidge(
        centerLat,
        centerLon,
        gridSize,
        resolution,
        baseElevation: 500.0,
        ridgeElevation: 999999.0,
      );

      //cross the ridge at center, user at 600m altitude
      final userPos = GpsPosition(
        lat: centerLat - 0.001,
        lon: centerLon,
        altitude: 600.0,
      );
      final waypointPos = GpsPosition(
        lat: centerLat + 0.001,
        lon: centerLon,
        altitude: 600.0,
      );

      final algo = Algo1D(
        waypointPos: waypointPos,
        userPos: userPos,
        maillage: 0.5,
        tilePath: '',
        f: 9,
        provider: ElevationProvider.sim,
      );

      final climbNeeded = await algo.runWithObstacle({}, tile);

      // Should need massive climb (wall at 999999m)
      expect(
        climbNeeded,
        greaterThan(50000.0),
      ); //this way we know the algorithm can be precise when needed
    });

    test('multiple ridges, highest obstacle test', () async {
      final centerLat = 46.997484;
      final centerLon = 6.938608;
      final gridSize = 6000;
      final resolution = 0.5;

      final tile = ElevationSim.generateMultipleRidges(
        centerLat,
        centerLon,
        gridSize,
        resolution,
        baseElevation: 500.0,
      );

      //cross every ridges in a diagonal way
      final userPos = GpsPosition(
        lat: centerLat - 0.002,
        lon: centerLon - 0.002,
        altitude: 1500.0,
      );
      final waypointPos = GpsPosition(
        lat: centerLat + 0.002,
        lon: centerLon + 0.002,
        altitude: 1500.0,
      );

      final algo = Algo1D(
        waypointPos: waypointPos,
        userPos: userPos,
        maillage: 0.5,
        tilePath: '',
        f: 9,
        provider: ElevationProvider.sim,
      );

      final climbNeeded = await algo.runWithObstacle({}, tile);

      //highest ridge is at 1200m, but user is at 1500m and losing altitude
      //user would need some climb or be marginal
      expect(climbNeeded, greaterThanOrEqualTo(0.0));
    });

    test('fineness ratio validation', () async {
      final centerLat = 46.997484;
      final centerLon = 6.938608;
      final gridSize = 6000;
      final resolution = 0.5;

      final tile = ElevationSim.generateFlatTerrain(
        centerLat,
        centerLon,
        gridSize,
        resolution,
      );

      //900m horizontal distance, f=9, need 100m altitude loss (d/f)
      //user is at 400m and should hit 500m terrain
      final userPos = GpsPosition(
        lat: centerLat - 0.004,
        lon: centerLon,
        altitude: 400.0,
      );
      final waypointPos = GpsPosition(
        lat: centerLat + 0.004,
        lon: centerLon,
        altitude: 400.0,
      );

      final algo = Algo1D(
        waypointPos: waypointPos,
        userPos: userPos,
        maillage: 0.5,
        tilePath: '',
        f: 9,
        provider: ElevationProvider.sim,
      );

      final climbNeeded = await algo.runWithObstacle({}, tile);

      //distance about 900m, glide to about 300m, terrain at 500m so user need 200m climb
      expect(climbNeeded, greaterThan(150.0));
      expect(climbNeeded, lessThan(250.0));
    });
  });
}
