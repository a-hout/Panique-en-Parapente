
import 'package:panique_en_parapente/service_elevation/elevation_data.dart';

abstract class ServiceElevation //interface
  {
    Future<ElevationData> fetchElevation(double lat, double lon, double radiusKm);
    
  }