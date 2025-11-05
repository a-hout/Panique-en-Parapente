class GpsPosition {
  final double lat;
  final double lon;
  final double altitude; //above sea levell
  final DateTime time;

  GpsPosition({
    required this.lat,
    required this.lon,
    required this.altitude,
    DateTime? time,
  }) : time = DateTime.now(); //generate tiem at constructor init

  void setPosition()
  /*
  calls the GPS service of the device to get current position
  */
  {}
}
