import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapViewScreen extends StatelessWidget {
  final LatLng hedefKonum;

  const MapViewScreen({Key? key, required this.hedefKonum}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📍 Hedef Konumu Görüntüle")),
      body: FlutterMap(
        options: MapOptions(
          center: hedefKonum,
          zoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.konumalarm',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 60,
                height: 60,
                point: hedefKonum,
                child: Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
