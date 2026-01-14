import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'download_screen.dart';

class WaypointPickerScreen extends StatefulWidget {
  @override
  State<WaypointPickerScreen> createState() => _WaypointPickerScreenState();
}

class _WaypointPickerScreenState extends State<WaypointPickerScreen> {
  LatLng? waypoint;
  double radius = 5.0; // km
  int fineness = 9;
  final MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Waypoint')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Image.asset('assets/logo.png', height: 60),
                SizedBox(height: 8),
                Text('Alex Houttuin', style: TextStyle(fontSize: 16)),
                Text(
                  'Panique en Parapente',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tous droits réservés',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(46.997406, 6.938268), //HE-ARC
                initialZoom: 13,
                onTap: (_, pos) => setState(() => waypoint = pos),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                if (waypoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: waypoint!,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                if (waypoint != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: waypoint!,
                        radius: radius * 1000, // meters
                        useRadiusInMeter: true,
                        color: Colors.blue.withOpacity(0.3),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Fineness: $fineness'),
                Slider(
                  value: fineness.toDouble(),
                  min: 6,
                  max: 14,
                  divisions: 8,
                  label: '$fineness',
                  onChanged: (v) => setState(() {
                    fineness = v.toInt();
                  }),
                ),
                Text('Radius: ${radius.toStringAsFixed(1)} km'),
                Slider(
                  value: radius,
                  min: 1,
                  max: 10,
                  divisions: 18,
                  label: '${radius.toStringAsFixed(1)} km',
                  onChanged: (v) => setState(() => radius = v),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: waypoint == null ? null : _confirm,
                  child: Text('Confirm'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DownloadScreen(
          waypoint: waypoint!,
          radius: radius,
          fineness: fineness,
        ),
      ),
    );
  }
}
