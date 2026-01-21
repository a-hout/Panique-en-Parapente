class BoundingBox {
  ///leftmost coord
  double minLat;

  ///rightmost coord
  double maxLat;

  ///bottommost coord
  double minLon;

  ///uppermost coord
  double maxLon;

  BoundingBox(this.minLat, this.maxLat, this.minLon, this.maxLon);

  ///get width of bounding box
  double get width => maxLon - minLon;

  ///get height of bounding box
  double get height => maxLat - minLat;
}
