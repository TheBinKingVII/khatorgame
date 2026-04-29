import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:khatorgame/core/errors/app_error_mapper.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/internetcafe_controller.dart';
import '../../domain/entities/internetcafe_entity.dart';

class InternetcafePage extends StatelessWidget {
  final MapController mapController = MapController();

  InternetcafePage({super.key});

  @override
  Widget build(BuildContext context) {
    final InternetcafeController controller = Get.find<InternetcafeController>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(54),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Warnet Radar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Temukan Warnet Terdekat',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        // State: Loading
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primary),
                const SizedBox(height: 20),
                const Text(
                  'Menghitung satelit\ndan lokasi kamu...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // State: Error
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Koneksi Bermasalah',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchLocationAndCafes(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                      shadowColor: primary.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final userPos = controller.userLocation.value;
        if (userPos == null) return const SizedBox.shrink();

        final userLatLng = LatLng(userPos.latitude, userPos.longitude);

        // Build map markers
        List<Marker> mapMarkers = [
          Marker(
            point: userLatLng,
            width: 50,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(color: primary.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)
                ],
              ),
              child: const Icon(Icons.my_location, color: Colors.white, size: 22),
            ),
          ),
        ];

        for (var cafe in controller.cafes) {
          mapMarkers.add(
            Marker(
              point: LatLng(cafe.latitude, cafe.longitude),
              width: 44,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 6, spreadRadius: 1)
                  ],
                ),
                child: const Icon(Icons.computer_rounded, color: Colors.white, size: 22),
              ),
            ),
          );
        }

        return Column(
          children: [
            // Peta
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: userLatLng,
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.khatorgame',
                      ),
                      PolylineLayer(
                        polylines: [
                          if (controller.routePoints.isNotEmpty)
                            Polyline(
                              points: controller.routePoints.toList(),
                              strokeWidth: 5.0,
                              color: primary,
                            ),
                        ],
                      ),
                      MarkerLayer(markers: mapMarkers),
                    ],
                  ),
                  // Info overlay jumlah warnet
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.store_rounded, size: 16, color: primary),
                          const SizedBox(width: 5),
                          Text(
                            '${controller.cafes.length} Warnet',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header daftar warnet
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Icons.list_rounded, color: primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Warnet Terdekat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),

            // Daftar Warnet
            Expanded(
              flex: 5,
              child: Container(
                color: const Color(0xFFF0F4F8),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  itemCount: controller.cafes.length,
                  itemBuilder: (context, index) {
                    final cafe = controller.cafes[index];
                    return _buildCafeCard(context, cafe, index);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCafeCard(BuildContext context, InternetcafeEntity cafe, int index) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            mapController.move(LatLng(cafe.latitude, cafe.longitude), 16.0);
            _showCafeDetails(context, cafe);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Nomor urut
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cafe.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cafe.address,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 13, color: Colors.amber[700]),
                          const SizedBox(width: 3),
                          Text(
                            cafe.rating.toString(),
                            style: TextStyle(fontSize: 12, color: Colors.amber[800], fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.monetization_on_rounded, size: 13, color: Colors.green[700]),
                          const SizedBox(width: 3),
                          Text(
                            cafe.pricePerHour,
                            style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Jarak
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(cafe.distance / 1000).toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    Text(
                      'KM',
                      style: TextStyle(fontSize: 10, color: primary.withOpacity(0.7), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCafeDetails(BuildContext context, InternetcafeEntity cafe) {
    final primary = Theme.of(context).colorScheme.primary;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header nama & rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.computer_rounded, color: primary, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cafe.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        cafe.rating.toString(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        Divider(color: Colors.grey[200]),
                        const SizedBox(height: 12),

                        // Info baris
                        _infoRow(Icons.location_on_rounded, Colors.redAccent,
                            '${cafe.address} • ${(cafe.distance / 1000).toStringAsFixed(1)} KM'),
                        const SizedBox(height: 10),
                        _infoRow(Icons.payments_rounded, Colors.green,
                            '${cafe.pricePerHour} / Jam'),

                        const SizedBox(height: 16),
                        Text(
                          'Fasilitas',
                          style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: cafe.facilities.map((fac) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primary.withOpacity(0.2)),
                            ),
                            child: Text(
                              fac,
                              style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.w500),
                            ),
                          )).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Tombol Rute
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Obx(() {
                            final InternetcafeController ctrl = Get.find<InternetcafeController>();
                            return ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: primary.withOpacity(0.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: ctrl.isFetchingRoute.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.route_rounded),
                              label: Text(
                                ctrl.isFetchingRoute.value ? 'Mencari Rute...' : 'Tampilkan Rute di Peta',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              onPressed: ctrl.isFetchingRoute.value
                                  ? null
                                  : () async {
                                      if (context.mounted) Navigator.pop(context);
                                      mapController.move(LatLng(cafe.latitude, cafe.longitude), 14.0);
                                      try {
                                        await ctrl.fetchRouteTo(cafe.latitude, cafe.longitude);
                                      } catch (error) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                mapErrorToUserMessage(error),
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                              backgroundColor: Colors.redAccent,
                                              behavior: SnackBarBehavior.floating,
                                              margin: const EdgeInsets.all(16),
                                            ),
                                          );
                                        }
                                      }
                                    },
                            );
                          }),
                        ),
                      ],
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

  Widget _infoRow(IconData icon, Color iconColor, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
          ),
        ),
      ],
    );
  }
}
