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
    final cafes = await repository.getCafesAround(lat, lng);

    for (var cafe in cafes) {
      double distanceInMeters = Geolocator.distanceBetween(
        lat, lng, cafe.latitude, cafe.longitude
      );
      cafe.distance = distanceInMeters;
    }

    cafes.sort((a, b) => a.distance.compareTo(b.distance));

    return cafes;
  }
}
