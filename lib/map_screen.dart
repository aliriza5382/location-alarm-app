import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const MapScreen({required this.onLocationSelected});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _initialPosition = LatLng(37.8746, 32.4932); // Konya merkez
  LatLng? _selectedPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hedef Konumu Seç")),
      body: FlutterMap(
        options: MapOptions(
          center: _initialPosition,
          zoom: 13,
          onTap: (tapPosition, point) {
            setState(() {
              _selectedPosition = point;
            });
            widget.onLocationSelected(point);
            Navigator.pop(context);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.konumalarm',
          ),
          if (_selectedPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 40,
                  height: 40,
                  point: _selectedPosition!,
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
