import '../../domain/entities/internetcafe_entity.dart';

class InternetcafeModel extends InternetcafeEntity {
  InternetcafeModel({
    required super.id,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.rating,
    required super.pricePerHourUsd,
    required super.facilities,
    super.distance = 0.0,
  });
}
