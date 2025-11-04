import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:panique_en_parapente/service_elevation/geotiff_loader.dart';
import 'package:panique_en_parapente/service_elevation/swisstopo_tile_downloader.dart';

void main() {
  group('Tile test', () {
    test('swisstopo downloader', () async {
      final downloader = SwisstopoTileDownloader();
      final bbox = SwisstopoTileDownloader.calculateBbox(
        46.9267,
        6.7267,
        0.2,
      ); //small radius to only get 1 or 2 tiles
      final tiles = await downloader.fetchTileUrls(
        bbox.minLon,
        bbox.minLat,
        bbox.maxLon,
        bbox.maxLat,
      );

      final files = await downloader.downloadTiles(tiles, './test_tiles');
      var empty = await Directory('./test_tiles').list().isEmpty;
      expect(empty, isFalse); //folder should not be empty
    });
    test('GeoTIFF loader', () async {
      final downloader = SwisstopoTileDownloader();
      final bbox = SwisstopoTileDownloader.calculateBbox(
        46.9267,
        6.7267,
        0.2,
      ); //small radius to only get 1 or 2 tiles
      final tiles = await downloader.fetchTileUrls(
        bbox.minLon,
        bbox.minLat,
        bbox.maxLon,
        bbox.maxLat,
      );

      final files = await downloader.downloadTiles(tiles, './test_tiles');

      final data = GeotiffLoader.loadGeoTiff(files[0], tiles[0].bbox);
      expect(data.elevations, isNotNull);
      expect(data.bounds, equals(tiles[0].bbox));
    });

    test('Le Soliat correct height', () async {
      final downloader = SwisstopoTileDownloader();
      final bbox = SwisstopoTileDownloader.calculateBbox(
        46.92891181685898,
        6.72484189994648,
        0.001,
      ); //Centered 10m around Le Soliat, we only want this one tile in memory

      final tiles = await downloader.fetchTileUrls(
        bbox.minLon,
        bbox.minLat,
        bbox.maxLon,
        bbox.maxLat,
      );

      final files = await downloader.downloadTiles(tiles, './test_tiles');

      //first tile, but should be the only tile
      final data = GeotiffLoader.loadGeoTiff(files[0], tiles[0].bbox);
      expect(data.rows, equals(2000));
      expect(data.cols, equals(2000));

      //test point in matrix data
      final elevation = data.getElevationGPS(
        46.92883854903777,
        6.724745340126811,
      );
      expect(
        elevation,
        moreOrLessEquals(1464.0, epsilon: 3.0),
      ); //3 meter tolerance
    });
  });
}
