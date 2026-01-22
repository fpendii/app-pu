import 'package:flutter/material.dart';

class PetaPage extends StatelessWidget {
  const PetaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Peta Sebaran Kerusakan")),
      body: Column(
        children: [
          // Simulasi Area Peta
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.blue[50],
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.map, size: 100, color: Colors.blueGrey),
                // Simulasi Marker Kuning PU
                Positioned(top: 50, left: 100, child: Icon(Icons.location_on, color: Colors.red, size: 40)),
                Positioned(bottom: 80, right: 120, child: Icon(Icons.location_on, color: Colors.orange, size: 40)),
                Positioned(top: 150, right: 50, child: Icon(Icons.location_on, color: Colors.red, size: 40)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Titik Lokasi Kerusakan Terkini", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildMapLegend("Kec. Cicendo", "3 Laporan", Colors.red),
                _buildMapLegend("Kec. Coblong", "1 Laporan", Colors.orange),
                _buildMapLegend("Kec. Andir", "5 Laporan", Colors.red),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMapLegend(String area, String count, Color color) {
    return ListTile(
      leading: Icon(Icons.pin_drop, color: color),
      title: Text(area),
      subtitle: Text(count),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}