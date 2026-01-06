import 'package:panique_en_parapente/analysis/utils/tile_download_util.dart';

//reliably fetches more than 100 tiles, useful for tile loading analysis
//run with flutter run -d windows -t lib\analysis\utils\download.dart, note that the data folder will be located OUTSIDE the working directory of flutter, so go one folder up from root to see them (a disadvantage of flutter development I guess)
Future<void> main() async {
  await TileDownloadUtil.downloadRange(5);
}
