import 'package:flutter/material.dart';
import 'package:panique_en_parapente/ui/waypoint_picker_screen.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized(); //geolocator doesnt work if it's not bound
  runApp(
    MaterialApp(home: WaypointPickerScreen()),
  ); //we start at the waypoint picker screen
}
