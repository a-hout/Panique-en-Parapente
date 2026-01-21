import 'package:panique_en_parapente/service_elevation/elevation_sim.dart';
import 'package:panique_en_parapente/service_elevation/service_elevation.dart';
import 'package:panique_en_parapente/service_elevation/swisstopo.dart';

class ServiceElevationFactory {
  static ServiceElevation create(
    double lat,
    double lon,
    ElevationProvider provider,
  ) {
    switch (provider) {
      case ElevationProvider.swisstopo:
        return SwissTopo();
      case ElevationProvider.sim:
        return ElevationSim();
    }
  }

  ///very simple, will try to see if lat and lon is in switzerland approximately /!\ if implementing a global tool -> refine this method
  static ElevationProvider findProvider(double lat, double lon) {
    //very simple, will try to see if lat and lon is in switzerland
    if (lat >= 45.82 && lat <= 47.8 && lon >= 5.97 && lon <= 10.49) {
      //gotten from this link https://web.archive.org/web/20150319012353/http://opengeocode.org/cude/download.php?file=/home/fashions/public_html/opengeocode.org/download/cow.txt
      return ElevationProvider.swisstopo;
    }
    return ElevationProvider.sim;
  }
}

enum ElevationProvider { swisstopo, sim }
