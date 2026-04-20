import 'dart:math';
import '../../domain/entities/internetcafe_entity.dart';

abstract class InternetcafeRemoteDataSource {
  Future<List<InternetcafeEntity>> getDummyCafes(double lat, double lng);
}

class InternetcafeRemoteDataSourceImpl implements InternetcafeRemoteDataSource {
  @override
  Future<List<InternetcafeEntity>> getDummyCafes(double lat, double lng) async {
    // Simulasi delay seakan-akan ngambil data dari internet (API)
    await Future.delayed(const Duration(milliseconds: 500));
    
    final random = Random();
    
    return [
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
  }
}
