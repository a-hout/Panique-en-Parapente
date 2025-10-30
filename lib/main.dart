import 'package:panique_en_parapente/service_elevation/elevation_sim.dart';
import 'package:panique_en_parapente/service_elevation/geotiff_loader.dart';
import 'package:panique_en_parapente/service_elevation/swisstopo_tile_downloader.dart';

Future<void> main(List<String> args) async {
  /*
  final downloader = SwisstopoTileDownloader();

  final bbox = SwisstopoTileDownloader.calculateBbox(46.94, 6.72, 2); //2 km around creux du van
  final urls = await downloader.fetchTileUrls(
    bbox.minLon, bbox.minLat, 
    bbox.maxLon, bbox.maxLat
  );

  print("Nb tiles: ${urls.length}"); //should output 25 tiles
  */
  final downloader = SwisstopoTileDownloader();
  final bbox = SwisstopoTileDownloader.calculateBbox(46.9267, 6.7267, 0.2);
  print('Bbox: ${bbox.minLat}, ${bbox.maxLat}, ${bbox.minLon}, ${bbox.maxLon}');

  final tiles = await downloader.fetchTileUrls(bbox.minLon, bbox.minLat, bbox.maxLon, bbox.maxLat);
  print('Found ${tiles.length} tiles');

  final files = await downloader.downloadTiles(tiles, './test_tiles');
  print('Downloaded ${files.length} files');

  //first tile
  final loader = GeotiffLoader();
  final data = loader.loadGeoTiff(files[0], tiles[0].bbox);
  print('Dimensions: ${data.rows}x${data.cols}');
  print('First 10 elevations: ${data.elevations.sublist(0, 10)}');
  print('Min: ${data.elevations.reduce((a,b) => a < b ? a : b)}m'); //instruction lambda to get the smallest value
  print('Max: ${data.elevations.reduce((a,b) => a > b ? a : b)}m');

  var sum = 0;
  for (var i = 0; i < data.elevations.length; i++) {
    if (data.elevations[i] == 0.0) {
      sum++;
    }
  }
  print('Number of null points: $sum');

  //test point in matrix data
  final elevation = data.getElevationGPS(46.9267, 6.7267);
  print('Creux du Van elevation: ${elevation}m (expect higher than 1000m)');
}
