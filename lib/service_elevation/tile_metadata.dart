import 'package:panique_en_parapente/service_elevation/bounding_box.dart';

class TileMetadata {
  final String url;
  final int x;
  final int y;
  final BoundingBox bbox;
  TileMetadata(this.url, this.x, this.y, this.bbox);
}
