import 'package:panique_en_parapente/service_elevation/elevation_data.dart';

import 'service_elevation.dart';

///not implemented, see other files except elevation_sim
class SwissTopo implements ServiceElevation {
  @override
  Future<ElevationData> fetchElevation(
    double lat,
    double lon,
    double radiusKm,
  ) async {
    //
    throw UnimplementedError("not implemented");
  }
}
