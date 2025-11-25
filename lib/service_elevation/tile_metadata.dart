import 'package:panique_en_parapente/service_elevation/bounding_box.dart';

class TileMetadata {
  ///link to tile
  final String url;

  ///easting in integer
  final int x;

  ///northing in integer
  final int y;

  ///bounding box of tile
  final BoundingBox bbox;
  TileMetadata(this.url, this.x, this.y, this.bbox);
}
