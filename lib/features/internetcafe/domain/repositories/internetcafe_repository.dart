import 'package:geolocator/geolocator.dart';
import '../entities/internetcafe_entity.dart';

abstract class InternetcafeRepository {
  Future<Position> getUserLocation();
  Future<List<InternetcafeEntity>> getCafesAround(double lat, double lng);
}
