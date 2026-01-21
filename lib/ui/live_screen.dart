import 'package:flutter/material.dart';
import 'package:panique_en_parapente/program_controller.dart';
import 'dart:async';

class LiveScreen extends StatefulWidget {
  ///the controller of the program, basically the manager
  final ProgramController controller;

  ///calibrated altitude is important to offset with gps altitude
  final double? calibratedAltitude;

  LiveScreen({required this.controller, required this.calibratedAltitude});

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  double climbDelta = 0;
  double altitudeWaypoint = 0;
  double distance = 0;
  double altitude = 0;
  double? calibratedAltitude = 0;
  bool running = false;
  Timer? uiTimer;

  @override
  void initState() {
    super.initState();
    if (widget.calibratedAltitude != null) {
      widget.controller.userPos.setActualPosition().then((_) {
        widget.controller.calibrateAltitude(widget.calibratedAltitude!);
      });
    }
    //ui update every second
    uiTimer = Timer.periodic(Duration(seconds: 1), (_) => _updateUI());
  }

  @override
  void dispose() {
    uiTimer?.cancel();
    widget.controller.end();
    super.dispose();
  }

  void _updateUI() {
    setState(() {
      altitude = widget.controller.userPos.altitude;
      distance = widget.controller.algo1d.getHaversineDistance();
      climbDelta = widget.controller.climbDelta;
      altitudeWaypoint = widget.controller.altitudeWaypoint;
    });
  }

  void _start() {
    setState(() => running = true);
    widget.controller.start();
  }

  void _stop() {
    setState(() => running = false);
    widget.controller.end();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Navigation')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatCard(
              icon: Icons.terrain,
              label: 'Altitude',
              value: '${altitude.toStringAsFixed(1)} m',
            ),
            SizedBox(height: 16),
            _StatCard(
              icon: Icons.navigation,
              label: 'Distance to Waypoint',
              value: '${(distance / 1000).toStringAsFixed(2)} km',
            ),
            SizedBox(height: 16),
            _StatCard(
              icon: Icons.arrow_upward,
              label: 'Climb Required',
              value: '${climbDelta.toStringAsFixed(1)} m',
              color: climbDelta > 0 ? Colors.orange : Colors.green,
            ),
            SizedBox(height: 16),
            _StatCard(
              icon: Icons.paragliding,
              label: 'Altitude at Waypoint',
              value: '${(altitudeWaypoint + climbDelta).toStringAsFixed(1)} m',
              color: (altitudeWaypoint + climbDelta) > 0
                  ? Colors.green
                  : Colors.red,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: running ? _stop : _start,
              style: ElevatedButton.styleFrom(
                backgroundColor: running ? Colors.red : Colors.green,
                minimumSize: Size(200, 50),
              ),
              child: Text(running ? 'Stop' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
