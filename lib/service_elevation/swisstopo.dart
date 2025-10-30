import 'package:panique_en_parapente/service_elevation/elevation_data.dart';

import 'service_elevation.dart';

class SwissTopo implements ServiceElevation
  {
  @override
  Future<ElevationData> fetchElevation(double lat, double lon, double radiusKm) async 
    {
      // TODO: implement fetchElevation with api data
      throw UnimplementedError("wip wait TODO");
    }
  }