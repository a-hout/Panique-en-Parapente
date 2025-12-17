import 'dart:io';
import 'package:panique_en_parapente/gps/gps_position.dart';
import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'package:panique_en_parapente/service_elevation/geotiff_loader.dart';
import 'package:panique_en_parapente/service_elevation/swisstopo_tile_downloader.dart';

class TileDownloadUtil {
  static final folder = "${Directory.current.parent.path}/data/temp/";

  ///download a select number of tiles in a vertical line up
  ///returns the waypoint of the point at x kilometers away
  static Future<GpsPosition> downloadNumber(int num) async {
    final downloader = SwisstopoTileDownloader();

    final latPerKm = 1 / 111.32;
    final startLat = 46.685213;
    final startLon = 7.853294;

    final bbox = BoundingBox(
      startLat,
      startLat + ((num - 1) * latPerKm), // line
      startLon,
      startLon + 0.00001, //tiny width
    ); //this is effectively a bounding line

    final metadata = await downloader.fetchTileUrls(
      bbox.minLon,
      bbox.minLat,
      bbox.maxLon,
      bbox.maxLat,
    );

    print("Downloading ${metadata.length} tiles...");

    await downloader.downloadTiles(metadata, folder);

    print("Download complete, generating waypoint ${num - 1} km away...");

    final tempWaypoint = GpsPosition(
      lat: startLat + ((num - 1) * latPerKm),
      lon: startLon,
      altitude: 0.0,
    );
    final gridWaypoint = tempWaypoint.getLV95();
    final tileWaypoint = await GeotiffLoader.loadGeoTiffByLV95(
      "${gridWaypoint[1]}-${gridWaypoint[0]}",
      folder,
    );
    final altitude = tileWaypoint.getElevationGPS(
      tempWaypoint.lat,
      tempWaypoint.lon,
    );
    final waypoint = GpsPosition(
      lat: tempWaypoint.lat,
      lon: tempWaypoint.lon,
      altitude: altitude,
    );

    return waypoint;
  }

  ///download tiles in a range (centered around interlaken for best coverage)
  static Future<void> downloadRange(double r) async {
    final downloader = SwisstopoTileDownloader();
    final bbox = SwisstopoTileDownloader.calculateBbox(46.685213, 7.853294, r);
    final metadata = await downloader.fetchTileUrls(
      bbox.minLon,
      bbox.minLat,
      bbox.maxLon,
      bbox.maxLat,
    );
    await downloader.downloadTiles(metadata, folder);
  }
}
