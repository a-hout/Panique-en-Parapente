

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:panique_en_parapente/service_elevation/geotiff_loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:panique_en_parapente/gps/gps_position.dart';
import 'package:panique_en_parapente/program_controller.dart';
import 'package:panique_en_parapente/service_elevation/swisstopo_tile_downloader.dart';
import 'live_screen.dart';

class DownloadScreen extends StatefulWidget {
  final LatLng waypoint;
  final double radius;
  final int fineness;

  DownloadScreen({
    required this.waypoint,
    required this.radius,
    required this.fineness,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  int progress = 0;
  int total = 0;
  bool downloading = true;
  ProgramController? controller;
  String? error;

  @override
  void initState() {
    super.initState();
    _downloadTiles();
  }

  Future<void> _downloadTiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tileFolder = '${appDir.path}/tiles/';

      final downloader = SwisstopoTileDownloader();
      final bbox = SwisstopoTileDownloader.calculateBbox(
        widget.waypoint.latitude,
        widget.waypoint.longitude,
        widget.radius,
      );

      final metadata = await downloader.fetchTileUrls(
        bbox.minLon,
        bbox.minLat,
        bbox.maxLon,
        bbox.maxLat,
      );

      setState(() => total = metadata.length);

      for (int i = 0; i < metadata.length; i++) {
        await downloader.downloadTile(metadata[i], tileFolder);
        setState(() => progress = i + 1);
      }

      //init controller
      final userPos = await GpsPosition.fromDevice();
      final waypointPosTemp = GpsPosition(
        lat: widget.waypoint.latitude,
        lon: widget.waypoint.longitude,
        altitude: 0, //not known
      );

      final waypointGrid = waypointPosTemp.getLV95();
      final waypointTile = await GeotiffLoader.loadGeoTiffByLV95(
        "${waypointGrid[1]}-${waypointGrid[0]}",
        tileFolder,
      );

      final waypointPos = GpsPosition(
        lat: widget.waypoint.latitude,
        lon: widget.waypoint.longitude,
        altitude: waypointTile.getElevationGPS(
          widget.waypoint.latitude,
          widget.waypoint.longitude,
        ),
      );

      controller = ProgramController(
        f: widget.fineness,
        r: widget.radius,
        waypointPos: waypointPos,
        userPos: userPos,
        tileFolder: tileFolder,
      );

      setState(() => downloading = false);
    } catch (e) {
      setState(() {
        error = e.toString();
        downloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Downloading Tiles')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (downloading) ...[
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text('Downloading tiles...'),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: total > 0 ? progress / total : 0,
                ),
                SizedBox(height: 8),
                Text('$progress / $total tiles'),
              ] else if (error != null) ...[
                Icon(Icons.error, color: Colors.red, size: 64),
                SizedBox(height: 16),
                Text('Error: $error'),
              ] else ...[
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 24),
                Text('Ready to launch!'),
                SizedBox(height: 24),
                ElevatedButton(onPressed: _launch, child: Text('Launch')),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _launch() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LiveScreen(controller: controller!)),
    );
  }
}
