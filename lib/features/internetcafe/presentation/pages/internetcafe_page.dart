import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/internetcafe_controller.dart';
import '../../domain/entities/internetcafe_entity.dart';

class InternetcafePage extends StatelessWidget {
  final MapController mapController = MapController(); // Controller tambahan untuk peta

  InternetcafePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Registrasi controller
    final controller = Get.put(InternetcafeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warnet Radar LBS'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Menghitung satelit dan lokasi kamu...')
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        final userPos = controller.userLocation.value;
        if (userPos == null) return const SizedBox.shrink();

        final userLatLng = LatLng(userPos.latitude, userPos.longitude);

        // Menyiapkan Marker Peta
        List<Marker> mapMarkers = [
          // Marker Lokasi User (Warna Biru)
          Marker(
            point: userLatLng,
            width: 50,
            height: 50,
            child: const Icon(
              Icons.my_location,
              color: Colors.blueAccent,
              size: 40,
            ),
          ),
        ];

        // Memasukkan Marker Warnet (Warna Merah)
        for (var cafe in controller.cafes) {
          mapMarkers.add(
            Marker(
              point: LatLng(cafe.latitude, cafe.longitude),
              width: 50,
              height: 50,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
        }

        return Column(
          children: [
            // BAGIAN ATAS: PETA
            Expanded(
              flex: 5, // 50% Layar buat Peta
              child: FlutterMap(
                mapController: mapController, // Hubungkan Map ke controller internal
                options: MapOptions(
                  initialCenter: userLatLng,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.khatorgame',
                  ),
                  MarkerLayer(markers: mapMarkers),
                ],
              ),
            ),

            // BAGIAN BAWAH: DAFTAR WARNET
            Expanded(
              flex: 5, // 50% Layar buat List
              child: Container(
                color: Colors.grey[50],
                child: ListView.builder(
                  itemCount: controller.cafes.length,
                  itemBuilder: (context, index) {
                    final cafe = controller.cafes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        onTap: () {
                          // ACTION 1: Geser map ke lokasi warnet
                          mapController.move(
                            LatLng(cafe.latitude, cafe.longitude), 
                            16.0 
                          );
                          // ACTION 2: Munculkan Bottom Sheet Detail
                          _showCafeDetails(context, cafe);
                        },
                        leading: const CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          child: Icon(Icons.computer, color: Colors.white),
                        ),
                        title: Text(cafe.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(cafe.address),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_walk, size: 20, color: Colors.grey),
                            Text(
                              '${(cafe.distance / 1000).toStringAsFixed(1)} KM',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showCafeDetails(BuildContext context, InternetcafeEntity cafe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // WAJIB: Agar tingginya bisa bebas dan tidak kepotong
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cafe.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange),
                      Text(
                        cafe.rating.toString(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '📍 ${cafe.address} • ${(cafe.distance / 1000).toStringAsFixed(1)} KM',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    '${cafe.pricePerHour} / Jam',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Fasilitas:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cafe.facilities.map((fac) => Chip(
                  label: Text(fac, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue[50],
                )).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Mulai Navigasi (Google Maps)', style: TextStyle(fontSize: 16)),
                  onPressed: () async {
                    // LINK GOOGLE MAPS UNTUK RUTE NAVIGASI (DIRECTION)
                    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${cafe.latitude},${cafe.longitude}');
                    
                    try {
                      // Bypass canLaunchUrl untuk menghindari error intent visibility di Android 11+
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      Get.snackbar('Error', 'Gagal membuka Google Maps');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
  }
}
