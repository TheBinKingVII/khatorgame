import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:khatorgame/core/errors/app_error_mapper.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/internetcafe_entity.dart';
import '../../domain/usecases/internetcafe_usecase.dart';

class InternetcafeController extends GetxController {
  final InternetcafeUsecase usecase;
  
  var cafes = <InternetcafeEntity>[].obs;
  var userLocation = Rxn<Position>();
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  // Untuk menyimpan garis rute di peta
  var routePoints = <LatLng>[].obs;
  var isFetchingRoute = false.obs;

  // Menyimpan koneksi live tracking
  StreamSubscription<Position>? _positionStream;

  InternetcafeController(this.usecase);

  @override
  void onInit() {
    super.onInit();
    fetchLocationAndCafes();
    _startLiveTracking();
  }

  @override
  void onClose() {
    _positionStream?.cancel(); // Mencegah memory leak saat ditutup
    super.onClose();
  }

  // Fungsi untuk update lokasi terus-menerus
  void _startLiveTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update titik biru jika user pindah minimal 5 meter
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        userLocation.value = position;
        // Lokasi "userLocation" di-observe oleh peta, jadi titik biru akan bergerak otomatis!
      },
    );
  }

  Future<void> fetchLocationAndCafes() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Cek Koneksi Internet Dulu
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw Exception('offline');
        }
      } catch (_) {
        throw Exception('Koneksi terputus. Pastikan jaringan internet stabil!');
      }

      Position position = await usecase.getUserLocation();
      userLocation.value = position;
      
      List<InternetcafeEntity> fetchedCafes = await usecase.getCafesAndCalculateDistance(
        position.latitude, 
        position.longitude
      );
      
      cafes.value = fetchedCafes;

    } catch (error) {
      errorMessage.value = mapErrorToUserMessage(
        error,
        fallbackMessage: 'Failed to load location and internet cafes. Try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Tarik data rute (Polyline) dari Open Source Routing Machine (OSRM)
  Future<void> fetchRouteTo(double destLat, double destLng) async {
    if (userLocation.value == null) return;
    
    isFetchingRoute.value = true;
    routePoints.clear(); // Hapus rute lama
    
    try {
      // 1. Cek Koneksi Internet Dulu
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw Exception('Koneksi terputus. Pastikan jaringan internet stabil!');
        }
      } catch (_) {
        throw Exception('Koneksi terputus. Pastikan jaringan internet stabil!');
      }

      final startLat = userLocation.value!.latitude;
      final startLng = userLocation.value!.longitude;
      
      // OSRM API menggunakan format: lon,lat;lon,lat
      final url = 'http://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$destLng,$destLat?geometries=geojson';
      
      final dio = Dio();
      final response = await dio.get(url);
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
          
          List<LatLng> points = [];
          for (var coord in coordinates) {
            // GeoJSON format adalah [longitude, latitude]
            points.add(LatLng(coord[1], coord[0]));
          }
          
          routePoints.value = points;
        }
      }
    } on DioException catch (error) {
      throw Exception(
        mapErrorToUserMessage(
          error,
          fallbackMessage: 'Failed to load route. Try again later.',
        ),
      );
    } catch (error) {
      throw Exception(
        mapErrorToUserMessage(
          error,
          fallbackMessage: 'Terjadi kesalahan tidak terduga.',
        ),
      );
    } finally {
      isFetchingRoute.value = false;
    }
  }
}
