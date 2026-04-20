import 'package:geolocator/geolocator.dart';

abstract class InternetcafeDeviceDataSource {
  Future<Position> getCurrentLocation();
}

class InternetcafeDeviceDataSourceImpl implements InternetcafeDeviceDataSource {
  @override
  Future<Position> getCurrentLocation() async {
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

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
  }
}
