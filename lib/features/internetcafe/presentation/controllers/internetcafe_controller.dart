import 'dart:math';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/internetcafe_entity.dart';

class InternetcafeController extends GetxController {
  var cafes = <InternetcafeEntity>[].obs;
  var userLocation = Rxn<Position>();
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan Lokasi (GPS) dinonaktifkan.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Akses lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Akses lokasi ditolak secara permanen. Silakan ubah di pengaturan HP.');
      }

      // Ambil koordinat saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      userLocation.value = position;
      
      // Setelah dapat titik aslimu, kita buatkan Warnet Dummy di sekitar situ
      _generateDummyCafesAround(position.latitude, position.longitude);

    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void _generateDummyCafesAround(double lat, double lng) {
    final random = Random();
    
    // Kita buat 5 warnet boongan dengan koordinat acak di sekitar user (radius ~1-3km)
    List<InternetcafeEntity> dummyData = [
      InternetcafeEntity(
        id: '1',
        name: 'Khator Gaming Center',
        address: 'Jl. Ahmad Yani No. 8',
        latitude: lat + (random.nextDouble() - 0.5) * 0.02,
        longitude: lng + (random.nextDouble() - 0.5) * 0.02,
        rating: 4.8,
        pricePerHour: 'Rp 6.000',
        facilities: ['RTX 4060', '144Hz Monitor', 'AC Dingin', 'Smoking Area'],
      ),
      InternetcafeEntity(
        id: '2',
        name: 'SuperNet',
        address: 'Jl. Sudirman Blok B',
        latitude: lat + (random.nextDouble() - 0.5) * 0.03,
        longitude: lng + (random.nextDouble() - 0.5) * 0.03,
        rating: 4.2,
        pricePerHour: 'Rp 4.000',
        facilities: ['GTX 1650', 'Mabar Area', 'Kantin'],
      ),
      InternetcafeEntity(
        id: '3',
        name: 'Wibunet',
        address: 'Gatot Subroto 11',
        latitude: lat + (random.nextDouble() - 0.5) * 0.01,
        longitude: lng + (random.nextDouble() - 0.5) * 0.01,
        rating: 4.9,
        pricePerHour: 'Rp 8.000',
        facilities: ['RTX 4070', '240Hz Monitor', 'VIP Room', 'Kopi Gratis'],
      ),
      InternetcafeEntity(
        id: '4',
        name: 'Toxic ESPORT Arena',
        address: 'Jl. Maju Mundur No. 99',
        latitude: lat + (random.nextDouble() - 0.5) * 0.04,
        longitude: lng + (random.nextDouble() - 0.5) * 0.04,
        rating: 4.5,
        pricePerHour: 'Rp 5.500',
        facilities: ['Gaming Chair', 'Mechanical Keyboard', 'AC'],
      ),
      InternetcafeEntity(
        id: '5',
        name: 'GGCafe',
        address: 'Perumahan Indah Asri',
        latitude: lat + (random.nextDouble() - 0.5) * 0.015,
        longitude: lng + (random.nextDouble() - 0.5) * 0.015,
        rating: 4.0,
        pricePerHour: 'Rp 3.000',
        facilities: ['PC Standar', 'Bisa Ngekost', 'Internet Kencang'],
      ),
    ];

    // Proses kalkulasi jarak (LBS Math)
    for (var cafe in dummyData) {
      // Geolocator punya built-in function buat ngukur jarak antar dua kordinat LBS
      double distanceInMeters = Geolocator.distanceBetween(
        lat, lng, cafe.latitude, cafe.longitude
      );
      cafe.distance = distanceInMeters;
    }

    // Urutkan warnet dari yang paling dekat
    dummyData.sort((a, b) => a.distance.compareTo(b.distance));

    cafes.value = dummyData;
  }
}
