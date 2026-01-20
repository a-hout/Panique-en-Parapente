import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:panique_en_parapente/algo/algo_1d.dart';
import 'package:panique_en_parapente/algo/tile_controller.dart';
import 'package:panique_en_parapente/gps/gps_position.dart';
import 'package:panique_en_parapente/service_elevation/elevation_factory.dart';
import 'package:panique_en_parapente/service_elevation/swisstopo_tile_downloader.dart';

class ProgramController {
  late final TileController tileController;
  late final Algo1D algo1d;
  final GpsPosition userPos;
  final String tileFolder;
  final int f;
  final double r;
  final GpsPosition waypointPos;
  final FlutterTts tts = FlutterTts();

  double climbDelta = 0;
  double altitudeWaypoint = 0;
  double?
  altitudeOffset; //gps offset from user inputted altitude (geolocation altitude is unreliable on its own)

  bool isProcessing =
      false; //flag that signals if this tick is still running or not
  Timer? timer; //? doesn't have to be instanced by constructor

  /// user input: fineness f, radius r, waypointPos
  /// init of the program with all relevant classes setup properly
  ProgramController({
    required this.f,
    required this.r,
    required this.waypointPos,
    required this.userPos,
    required this.tileFolder,
  }) {
    tileController = TileController(
      tileFolder: tileFolder,
      endX: waypointPos.getLV95()[0],
      endY: waypointPos.getLV95()[1],
    );

    algo1d = Algo1D(
      f: f,
      userPos: userPos,
      waypointPos: waypointPos,
      maillage: 0.5,
      tilePath: tileFolder,
      provider: ElevationProvider.swisstopo,
    );
  }

  /// will start the program
  void start() {
    tick();

    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      tick();
    }); //callback will call the tick method every 10 seconds
  }

  /// will execute the algorithm every x seconds (default: 10 seconds)
  /// asynchronous to prevent this function to be called again if it takes >x seconds to compute
  Future<void> tick() async {
    if (isProcessing) return;
    isProcessing = true;

    try {
      //user position update
      await userPos.setActualPosition();

      if (altitudeOffset != null) {
        userPos.altitude = userPos.altitude - altitudeOffset!;
      }
      //tile controller updates with bresenham and loads in memory the tiles
      await tileController.run(
        userPos.getLV95()[0],
        userPos.getLV95()[1],
      ); //tiles HAVe to load otherwise race condition with algorithm

      //algo1d runs the algorithm with the provided tiles
      final result = await algo1d.runWithObstacle(
        tileController.tilesInMemory,
        null,
      );

      climbDelta = result.$1;
      altitudeWaypoint = result.$2;

      await tts.setLanguage(
        'en-GB',
      ); //british voices sound more professional than the american ones

      await tts.setSpeechRate(
        0.45,
      ); //slow down speech to make it easier to understand

      await tts.speak(
        'Climb ${climbDelta.round()} meters. Altitude at waypoint will be ${altitudeWaypoint.round()} meters.',
      );
    } catch (e) {
      print("Error during program: $e");
    } finally {
      isProcessing = false;
    }
  }

  /// will end the program
  void end() {
    timer?.cancel(); //if there is a timer, cancel it
  }

  ///calibrates the altitude between take off and ellipsoid
  void calibrateAltitude(double trueAltitude) {
    userPos.setActualPosition(); //get ellipsoid altitude before take off
    altitudeOffset = userPos.altitude - trueAltitude;
  }

  ///will download the tiles
  Future<void> downloadTiles() async {
    final downloader = SwisstopoTileDownloader();
    final bbox = SwisstopoTileDownloader.calculateBbox(
      waypointPos.lat,
      waypointPos.lon,
      r,
    );

    final metadata = await downloader.fetchTileUrls(
      bbox.minLon,
      bbox.minLat,
      bbox.maxLon,
      bbox.maxLat,
    );
    await downloader.downloadTiles(metadata, tileFolder);
  }
}
