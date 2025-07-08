import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'map_screen.dart';
import 'map_view_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(KonumAlarmApp());
}

class KonumAlarmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Konum Alarm',
      theme: ThemeData(
        primaryColor: Color(0xFF121E2D),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF121E2D),
          foregroundColor: Colors.white,
        ),
      ),
      home: KonumEkrani(),
    );
  }
}

class KonumEkrani extends StatefulWidget {
  @override
  _KonumEkraniState createState() => _KonumEkraniState();
}

class _KonumEkraniState extends State<KonumEkrani> {
  String _konum = "Konum alınamadı";
  TextEditingController hedefLatController = TextEditingController();
  TextEditingController hedefLongController = TextEditingController();
  TextEditingController mesafeLimitController = TextEditingController();
  TextEditingController adresController = TextEditingController();
  double? mesafe;

  Timer? takipZamani;
  bool alarmCaldiMi = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _konumuAlVeHesapla() async {
    var status = await Permission.location.request();
    if (!status.isGranted) {
      setState(() {
        _konum = "Konum izni verilmedi.";
      });
      return;
    }

    Position mevcutKonum = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    double hedefLat = double.tryParse(hedefLatController.text) ?? 0.0;
    double hedefLong = double.tryParse(hedefLongController.text) ?? 0.0;

    final distance = latlng.Distance();
    double hesaplananMesafe = distance.as(
      latlng.LengthUnit.Meter,
      latlng.LatLng(mevcutKonum.latitude, mevcutKonum.longitude),
      latlng.LatLng(hedefLat, hedefLong),
    );

    setState(() {
      _konum =
      "Mevcut: (${mevcutKonum.latitude}, ${mevcutKonum.longitude})\nHedef: ($hedefLat, $hedefLong)";
      mesafe = hesaplananMesafe;
    });

    double limit = (double.tryParse(mesafeLimitController.text) ?? 0) * 1000;
    if (hesaplananMesafe <= limit) {
      _alarmCal();
    }
  }

  void _alarmCal() async {
    print(">>> ALARM ÇALIŞTI <<<");
    await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("📍 Hedefe Yaklaşıldı!"),
        content: Text("Belirttiğin mesafenin altına girildi."),
        actions: [
          TextButton(
            child: Text("Tamam"),
            onPressed: () {
              _audioPlayer.stop();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  void _otomatikTakibiBaslat() async {
    print(">>> Otomatik Takip Başlatılıyor...");

    var status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      setState(() {
        _konum = "Konum izni verilmedi (takip için).";
      });
      return;
    }

    double hedefLat = double.tryParse(hedefLatController.text) ?? 0.0;
    double hedefLong = double.tryParse(hedefLongController.text) ?? 0.0;
    double limit = (double.tryParse(mesafeLimitController.text) ?? 0.0) * 1000;

    if (hedefLat == 0.0 || hedefLong == 0.0 || limit == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Lütfen tüm bilgileri doğru girin."),
      ));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TakipDurumEkrani(
          hedefLat: hedefLat,
          hedefLong: hedefLong,
          mesafeLimit: limit,
        ),
      ),
    );
  }


  Future<void> _adresiKoordinataCevir() async {
    try {
      List<Location> locations =
      await locationFromAddress(adresController.text);
      if (locations.isNotEmpty) {
        var loc = locations.first;
        hedefLatController.text = loc.latitude.toStringAsFixed(6);
        hedefLongController.text = loc.longitude.toStringAsFixed(6);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Konum bulundu: ${loc.latitude}, ${loc.longitude}"),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Konum bulunamadı: $e"),
      ));
    }
  }

  @override
  void dispose() {
    hedefLatController.dispose();
    hedefLongController.dispose();
    mesafeLimitController.dispose();
    adresController.dispose();
    takipZamani?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📍 Konum Alarm Uygulaması"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Hedef Konum Bilgileri",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              TextField(
                controller: adresController,
                decoration: InputDecoration(
                  labelText: "Adres Gir (Örn: Konya Acar Market)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _adresiKoordinataCevir,
                icon: Icon(Icons.search),
                label: Text("Adresten Konum Al"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF121E2D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: hedefLatController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Hedef Enlem (Latitude)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: hedefLongController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Hedef Boylam (Longitude)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pin_drop),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: mesafeLimitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Alarm Mesafesi (Kilometre)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tune),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        onLocationSelected: (konum) {
                          hedefLatController.text =
                              konum.latitude.toStringAsFixed(6);
                          hedefLongController.text =
                              konum.longitude.toStringAsFixed(6);
                        },
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.map),
                label: Text("Haritadan Hedef Konum Seç"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF121E2D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              Divider(height: 30),
              ElevatedButton.icon(
                onPressed: _konumuAlVeHesapla,
                icon: Icon(Icons.calculate),
                label: Text("Mesafeyi Hesapla ve Alarm Kontrolü Yap"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF121E2D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              Text(_konum),
              if (mesafe != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    "🕥 Hedefe Olan Mesafe: ${mesafe!.toStringAsFixed(2)} metre",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              Divider(height: 30),
              ElevatedButton.icon(
                onPressed: _otomatikTakibiBaslat,
                icon: Icon(Icons.play_arrow),
                label: Text("Otomatik Takibi Başlat"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF121E2D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  takipZamani?.cancel();
                  alarmCaldiMi = false;
                },
                icon: Icon(Icons.stop),
                label: Text("Takibi Durdur"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF121E2D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF121E2D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  double lat =
                      double.tryParse(hedefLatController.text) ?? 0.0;
                  double long =
                      double.tryParse(hedefLongController.text) ?? 0.0;
                  if (lat != 0.0 && long != 0.0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MapViewScreen(hedefKonum: LatLng(lat, long)),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.remove_red_eye_outlined),
                label: Text("Hedefi Haritada Göster"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TakipDurumEkrani extends StatefulWidget {
  final double hedefLat;
  final double hedefLong;
  final double mesafeLimit;

  TakipDurumEkrani({
    required this.hedefLat,
    required this.hedefLong,
    required this.mesafeLimit,
  });

  @override
  _TakipDurumEkraniState createState() => _TakipDurumEkraniState();
}

class _TakipDurumEkraniState extends State<TakipDurumEkrani> {
  Timer? _timer;
  String bilgi = "Takip başlatılıyor...";
  double? mesafe;
  bool alarmCaldi = false;
  final distance = latlng.Distance();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
      Position konum = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double hesaplananMesafe = distance.as(
        latlng.LengthUnit.Meter,
        latlng.LatLng(konum.latitude, konum.longitude),
        latlng.LatLng(widget.hedefLat, widget.hedefLong),
      );

      setState(() {
        bilgi =
        "📍 Mevcut: (${konum.latitude}, ${konum.longitude})\n🎯 Hedef: (${widget.hedefLat}, ${widget.hedefLong})";
        mesafe = hesaplananMesafe;
      });

      if (hesaplananMesafe <= widget.mesafeLimit && !alarmCaldi) {
        alarmCaldi = true;
        _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("🚨 Yaklaşıldı!"),
            content: Text("Hedefe olan mesafe ${hesaplananMesafe.toStringAsFixed(2)} m"),
            actions: [
              TextButton(
                onPressed: () {
                  _audioPlayer.stop();
                  Navigator.of(context).pop();
                },
                child: Text("Tamam"),
              )
            ],
          ),
        );
        _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Takip Durumu")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bilgi, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            if (mesafe != null)
              Text("🕓 Anlık Mesafe: ${mesafe!.toStringAsFixed(2)} metre",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}




