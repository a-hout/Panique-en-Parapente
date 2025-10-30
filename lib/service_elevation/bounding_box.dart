class BoundingBox {
  final double minLat;
  final double maxLat;
  final double minLon;
  final double maxLon;

  BoundingBox(this.minLat, this.maxLat, this.minLon, this.maxLon);

  double get width => maxLon - minLon;
  double get height => maxLat - minLat;
}