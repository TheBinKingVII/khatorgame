import 'package:geolocator/geolocator.dart';
import '../entities/internetcafe_entity.dart';
import '../repositories/internetcafe_repository.dart';

class InternetcafeUsecase {
  final InternetcafeRepository repository;

  InternetcafeUsecase(this.repository);

  Future<Position> getUserLocation() {
    return repository.getUserLocation();
  }

  Future<List<InternetcafeEntity>> getCafesAndCalculateDistance(double lat, double lng) async {
    // 1. Ambil data warnet
    final cafes = await repository.getCafesAround(lat, lng);

    // 2. Kalkulasi jarak masing-masing warnet ke user
    for (var cafe in cafes) {
      double distanceInMeters = Geolocator.distanceBetween(
        lat, lng, cafe.latitude, cafe.longitude
      );
      cafe.distance = distanceInMeters;
    }

    // 3. Urutkan dari yang terdekat
    cafes.sort((a, b) => a.distance.compareTo(b.distance));

    return cafes;
  }
}
