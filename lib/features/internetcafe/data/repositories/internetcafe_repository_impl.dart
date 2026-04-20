import 'package:geolocator/geolocator.dart';
import '../../domain/entities/internetcafe_entity.dart';
import '../../domain/repositories/internetcafe_repository.dart';
import '../datasources/internetcafe_device_data_source.dart';
import '../datasources/internetcafe_remote_data_source.dart';

class InternetcafeRepositoryImpl implements InternetcafeRepository {
  final InternetcafeDeviceDataSource deviceDataSource;
  final InternetcafeRemoteDataSource remoteDataSource;

  InternetcafeRepositoryImpl({
    required this.deviceDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Position> getUserLocation() {
    return deviceDataSource.getCurrentLocation();
  }

  @override
  Future<List<InternetcafeEntity>> getCafesAround(double lat, double lng) {
    return remoteDataSource.getDummyCafes(lat, lng);
  }
}
