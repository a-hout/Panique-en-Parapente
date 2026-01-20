import 'package:flutter_test/flutter_test.dart';
import 'package:panique_en_parapente/service_elevation/elevation_sim.dart';

void main() {
  group('sim_test', () {
    test('data_generation', () async {
      final service = ElevationSim();
      final data = await service.fetchElevation(46.5, 6.5, 2);

      final ridgeData = ElevationSim.generateSingleRidge(
        46.5,
        6.5,
        1200,
        0.5,
      ); //maillage (chain?) of 0.5m
      final multiData = ElevationSim.generateMultipleRidges(
        46.5,
        6.5,
        1200,
        0.5,
      );

      expect(data.elevations, isNotNull);
      expect(ridgeData.elevations, isNotNull);
      expect(multiData.elevations, isNotNull);
    });
    test('get_elevation', () async {
      final service = ElevationSim();
      final data = await service.fetchElevation(46.5, 6.5, 2);

      final ridgeData = ElevationSim.generateSingleRidge(
        46.5,
        6.5,
        1200,
        0.5,
      ); //maillage (chain?) of 0.5m

      final elevationInterpolationTest = data.getElevationGPS(
        46.50005,
        6.50005,
      ); //0.0005 is about 5.5m different
      final elevation = data.getElevationGPS(46.5, 6.5);
      expect(elevation, equals(500));
      expect(
        elevationInterpolationTest,
        moreOrLessEquals(500),
      ); //interpolation gives a slightly different result

      final ridgeElevationInterpolationTest = ridgeData.getElevationGPS(
        46.50005,
        6.50007,
      ); //should output 500
      final ridgeElevationInterpolationTest2 = ridgeData.getElevationGPS(
        46.50005,
        6.50006,
      ); //should output 1500
      final ridgeElevation = ridgeData.getElevationGPS(
        46.5,
        6.5,
      ); //outputs 1500
      expect(ridgeElevationInterpolationTest, equals(500));
      expect(ridgeElevationInterpolationTest2, equals(1500));
      expect(ridgeElevation, equals(1500));
    });
  });
}
