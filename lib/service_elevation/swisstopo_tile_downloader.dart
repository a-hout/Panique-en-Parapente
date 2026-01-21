import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'package:panique_en_parapente/service_elevation/tile_metadata.dart';
import 'package:path/path.dart' as path;

class SwisstopoTileDownloader {
  ///the api url
  static const String stacBaseUrl =
      "https://data.geo.admin.ch/api/stac/v0.9/collections/ch.swisstopo.swisssurface3d-raster/items";

  /// fetches the tiles using the provided bounding box with the api
  Future<List<TileMetadata>> fetchTileUrls(
    double minLon,
    double minLat,
    double maxLon,
    double maxLat,
  ) async {
    //create string from bounding box coordinates to pass as parameter to stac api
    final bbox = "$minLon,$minLat,$maxLon,$maxLat";

    final allMetadata = <TileMetadata>[];

    //if there are more than 100 items from the api, need to go to the next link to find the other tiles
    String? nextUrl = '$stacBaseUrl?bbox=$bbox';
    while (nextUrl != null) {
      final response = await http.get(Uri.parse(nextUrl));

      if (response.statusCode != 200) {
        throw Exception('Api did not return data: ${response.statusCode}');
      }

      final json = jsonDecode(response.body);
      final features =
          json['features']
              as List; //in json file, the files to download are stocked in links within the features

      for (var feature in features) {
        final parts = feature['id'].split('_').last.split('-');
        final int x = int.parse(parts[0]);
        final int y = int.parse(parts[1]);
        final bboxList =
            feature['bbox']
                as List; //we want to name the tile files after their bounding box coordinates, make it easier to transform into elevation data
        final bboxTile = BoundingBox(
          bboxList[1],
          bboxList[3],
          bboxList[0],
          bboxList[2],
        );
        final assets =
            feature['assets']
                as Map<
                  String,
                  dynamic
                >; //under assets is a key that ends with .tif amongst others, that one has the href we are looking for
        for (var entry in assets.entries) {
          if (entry.key.endsWith('.tif')) {
            final href = entry.value['href'] as String;
            allMetadata.add(TileMetadata(href, x, y, bboxTile));
            break; //we only want the .tif link
          }
        }
      }
      final links = json['links'] as List;
      nextUrl = null;
      for (var link in links) {
        if (link['rel'] == 'next') {
          nextUrl = link['href'];
          break;
        }
      }
    }
    return allMetadata;
  }

  ///downloads one file from given url
  Future<File> downloadTile(
    TileMetadata metadata,
    String outputDirectory,
  ) async {
    final response = await http.get(
      Uri.parse(metadata.url),
    ); //get the .tif file of the tile
    if (response.statusCode != 200) {
      throw Exception("Could not retrieve tile: ${response.statusCode}");
    }

    final filename =
        '${metadata.x}-${metadata.y}-${metadata.bbox.minLat}-${metadata.bbox.maxLat}-${metadata.bbox.minLon}-${metadata.bbox.maxLon}.tif'; //naming convention makes it easier to get bounding box and grid index from the name, don't have to hold all data in ram that way
    final file = File(path.join(outputDirectory, filename));

    await file.create(recursive: true);
    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  /// parallelizes the downloads (still bottleneck of network speed present)
  Future<List<File>> downloadTiles(
    List<TileMetadata> metadatas,
    String outputDirectory,
  ) async {
    final futures = metadatas.map((m) => downloadTile(m, outputDirectory));
    return await Future.wait(futures);
  }

  ///calculates the bounding box needed to input into the STAC Api. Gets the position of the waypoint and roaming radius to determine the box.
  ///similar to _createBounds by elevation_sim, but bespoke for the swisstopo tiles
  static BoundingBox calculateBbox(
    double centerLat,
    double centerLon,
    double radiusKm,
  ) {
    const latPerKm =
        1 /
        111.32; //magic number is how much a km per degree is at switzerland latitude
    const lonPerKm = 1 / 78.85;

    final latDelta = radiusKm * latPerKm;
    final lonDelta = radiusKm * lonPerKm;
    return BoundingBox(
      centerLat - latDelta,
      centerLat + latDelta,
      centerLon - lonDelta,
      centerLon + lonDelta,
    );
  }
}
