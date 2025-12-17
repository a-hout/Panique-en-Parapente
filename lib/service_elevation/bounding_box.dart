class BoundingBox {
  double minLat;
  double maxLat;
  double minLon;
  double maxLon;

  BoundingBox(this.minLat, this.maxLat, this.minLon, this.maxLon);

  double get width => maxLon - minLon;
  double get height => maxLat - minLat;
}
