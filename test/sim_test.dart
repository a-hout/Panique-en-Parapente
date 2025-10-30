import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sim_test', () {
    //see if flat terrain 500m everywhere
    //see if single ridge makes a 1000m wall in the middle
    //log memory usage to see if it's a good idea to use Float32List
      
    //test sim, should move this to a unit test
    /*
    final service = ElevationSim();
    final data = await service.fetchElevation(46.5, 6.5, 5);

    final ridgeData = ElevationSim.generateSingleRidge(46.5, 6.5, 1200, 0.5); //maillage (chain?) of 0.5m
    final multiData = ElevationSim.generateMultipleRidges(46.5, 6.5, 1200, 0.5);

    final elevationInterpolationTest = data.getElevationGPS(46.50005, 6.50005); //0.0005 is about 5.5m different
    final elevation = data.getElevationGPS(46.5, 6.5);
    print("Bilinear elevation: $elevationInterpolationTest");
    print("Elevation: $elevation");

    print("\n");

    final ridgeElevationInterpolationTest = ridgeData.getElevationGPS(46.50005, 6.50007); //should output 500
    final ridgeElevationInterpolationTest2 = ridgeData.getElevationGPS(46.50005, 6.50006); //should output 1500
    final ridgeElevation = ridgeData.getElevationGPS(46.5, 6.5); //outputs 1500
    print("Ridge Bilinear elevation: $ridgeElevationInterpolationTest");
    print("Ridge Bilinear elevation 2: $ridgeElevationInterpolationTest2");
    print("Ridge Elevation: $ridgeElevation");

    print("\n");

    final multiElevationInterpolationTest = multiData.getElevationGPS(46.50005, 6.50005);
    final multiElevation = multiData.getElevationGPS(46.5, 6.5);
    print("Multi ridge Bilinear elevation: $multiElevationInterpolationTest");
    print("Multi ridge Elevation: $multiElevation");
    */
    

  });
}