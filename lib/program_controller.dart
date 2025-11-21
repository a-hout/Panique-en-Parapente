import 'package:panique_en_parapente/algo/algo1d.dart';
import 'package:panique_en_parapente/algo/tile_controller.dart';
import 'package:panique_en_parapente/gps/gps_position.dart';

class ProgramController {
  TileController tileController;
  Algo1D algo1d;
  GpsPosition userPos;
  final int f;
  final double r;
  final GpsPosition waypointPos;

  ProgramController(this.f, this.r, this.waypointPos): tileController = TileController(), userPos = GpsPosition(lat: 0,lon: 0, altitude: 0);
  /// user input: fineness f, radius r, waypointPos
  /// init of the program with all relevant classes setup properly
  {
    // get all tiles
    // get maillage from tiles
    //
    //
    algo1d = Algo1D(f: f, userPos:userPos, waypointPos: waypointPos);
    tileController = TileController();
  }

  void start()
  /// will start the program
  {
    print("/!\\ START PROGRAM\n\n");
    algo1d = Algo1D()
  }

  Future<void> tick() async
  /// will execute the algorithm every x seconds (default: 10 seconds)
  /// asynchronous to prevent this function to be called again if it takes >x seconds to compute
  {

  }

  void end()
  /// will end the program
  {
    print("\n\n/!\\ END PROGRAM");
  }
}
