import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:panique_en_parapente/service_elevation/bounding_box.dart';
import 'package:panique_en_parapente/service_elevation/tile_metadata.dart';
import 'package:path/path.dart' as path;

class SwisstopoTileDownloader {
  static const String stacBaseUrl = "https://data.geo.admin.ch/api/stac/v0.9/collections/ch.swisstopo.swisssurface3d-raster/items"; //to this url we will add the bounding box made from the radius set by the user
  Future<List<TileMetadata>> fetchTileUrls(double minLon, double minLat, double maxLon, double maxLat) async
  {
    final bbox = "$minLon,$minLat,$maxLon,$maxLat"; //create string from bounding box coordinates to pass as parameter to stac api
    final url = Uri.parse('$stacBaseUrl?bbox=$bbox'); //url in full
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Api did not return data: ${response.statusCode}');
    }

    final json = jsonDecode(response.body); //it's in json format
    final features = json['features'] as List; //in json file, the files to download are stocked in links within the features

    final urls = <TileMetadata>[];
    for (var feature in features) {
      final bboxList = feature['bbox'] as List; //we want to name the tile files after their bounding box coordinates, make it easier to transform into elevation data
      final bboxTile = BoundingBox(bboxList[1], bboxList[3], bboxList[0], bboxList[2]);
      final assets = feature['assets'] as Map<String, dynamic>; //under assets is a key that ends with .tif amongst others, that one has the href we are looking for
      for (var entry in assets.entries)
      {
        if (entry.key.endsWith('.tif'))
        {
          final href = entry.value['href'] as String;
          urls.add(TileMetadata(href, bboxTile));
          break; //we only want the .tif link
        }
      }
    }

    return urls;

  }

  Future<File> downloadTile(TileMetadata metadata, String outputDirectory) async
  /*
  downloads one file from given url
  */
  {
    final response = await http.get(Uri.parse(metadata.url)); //get the .tif file of the tile
    if (response.statusCode != 200)
    {
      throw Exception("Could not retrieve tile: ${response.statusCode}");
    }

    final filename ='${metadata.bbox.minLat}-${metadata.bbox.maxLat}-${metadata.bbox.minLon}-${metadata.bbox.maxLon}.tif'; //naming convention makes it easier to get bounding box from the name, don't have to hold all data in ram that way
    final file = File(path.join(outputDirectory, filename));

    await file.create(recursive: true);
    await file.writeAsBytes(response.bodyBytes);

    return file;
  }


  Future<List<File>> downloadTiles(List<TileMetadata> metadatas, String outputDirectory) async
  /*
  downloads all tiles from api
  */
  {
    Directory(outputDirectory).deleteSync(recursive: true); //should cache existing tiles if they're reused here
    final files = <File>[];
    for (var metadata in metadatas)
    {
      final file = await downloadTile(metadata, outputDirectory);
      files.add(file);
    }
    return files;
  }

  static BoundingBox calculateBbox(double centerLat, double centerLon, double radiusKm)
  /*
  Calculates the bounding box needed to input into the STAC Api. Gets the position of the waypoint and roaming radius to determine the box.
  */
  {
    const latPerKm = 1 /111.32; //magic number is how much a km per degree is at switzerland latitude
    const lonPerKm = 1 /78.85;

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