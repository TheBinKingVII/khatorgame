class InternetcafeEntity {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final String pricePerHourUsd;
  final List<String> facilities;
  double distance;

  InternetcafeEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.pricePerHourUsd,
    required this.facilities,
    this.distance = 0.0, // Default 0 sebelum dihitung
  });
}
