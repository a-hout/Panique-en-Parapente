import 'dart:io';

///utility class to easily save data as csv
///use: SaveToCsv.save('/path/to/file.csv', data)
///be sure to include the column headers in the data
class SaveToCsv {
  static void save(String filename, List<List<dynamic>> data) {
    final csv = data.map((row) => row.join(',')).join('\n');
    File(filename).writeAsStringSync(csv);
  }
}
