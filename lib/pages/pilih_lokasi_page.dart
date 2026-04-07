import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http; // Tambahkan http di pubspec.yaml
import 'dart:convert';

class PilihLokasiPage extends StatefulWidget {
  const PilihLokasiPage({super.key});

  @override
  State<PilihLokasiPage> createState() => _PilihLokasiPageState();
}

class _PilihLokasiPageState extends State<PilihLokasiPage> {
  LatLng _point = const LatLng(-3.8016, 114.7645); // Koordinat Tanah Laut
  String _alamatLengkap = "Mencari alamat...";
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getAlamat(_point);
  }

  // FUNGSI PENCARIAN ALAMAT (Search)
  Future<void> _cariAlamat() async {
    if (_searchController.text.isEmpty) return;

    final query = _searchController.text;
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'E-LaporPU-App', // Wajib ada agar tidak diblokir
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat']);
          double lon = double.parse(
            data[0]['display_name'] != null ? data[0]['lon'] : '0',
          );

          LatLng newPos = LatLng(lat, lon);
          setState(() {
            _point = newPos;
            _alamatLengkap = data[0]['display_name'];
          });

          // Gerakkan kamera peta ke lokasi baru
          _mapController.move(newPos, 15.0);
        } else {
          _showError("Alamat tidak ditemukan");
        }
      }
    } catch (e) {
      _showError("Terjadi kesalahan koneksi");
    }
  }

  Future<void> _getAlamat(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _alamatLengkap =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}";
        });
      }
    } catch (e) {
      setState(
        () => _alamatLengkap =
            "Koordinat: ${position.latitude}, ${position.longitude}",
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Titik Lokasi')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _point,
              initialZoom: 15.0,
              onTap: (tapPosition, latLng) {
                setState(() {
                  _point = latLng;
                  _alamatLengkap = "Mencari alamat...";
                });
                _getAlamat(latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.elapor.pu',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _point,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      size: 45,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // --- KOLOM PENCARIAN (Atas) ---
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  const BoxShadow(color: Colors.black26, blurRadius: 5),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Cari nama jalan/tempat...",
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.blue),
                    onPressed: _cariAlamat,
                  ),
                ),
                onSubmitted: (value) => _cariAlamat(),
              ),
            ),
          ),

          // --- PANEL INFORMASI (Bawah) ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _alamatLengkap,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.pop(context, {
                        'lat': _point.latitude,
                        'long': _point.longitude,
                        'alamat': _alamatLengkap,
                      });
                    },
                    child: const Text(
                      "KONFIRMASI LOKASI",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
