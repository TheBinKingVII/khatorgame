import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/internetcafe_entity.dart';
import '../../domain/usecases/internetcafe_usecase.dart';

class InternetcafeController extends GetxController {
  final InternetcafeUsecase usecase;
  
  var cafes = <InternetcafeEntity>[].obs;
  var userLocation = Rxn<Position>();
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  InternetcafeController(this.usecase);

  @override
  void onInit() {
    super.onInit();
    _fetchLocationAndCafes();
  }

  Future<void> _fetchLocationAndCafes() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Dapatkan Lokasi User dari Usecase
      Position position = await usecase.getUserLocation();
      userLocation.value = position;
      
      // 2. Dapatkan Warnet beserta Kalkulasi Jarak dari Usecase
      List<InternetcafeEntity> fetchedCafes = await usecase.getCafesAndCalculateDistance(
        position.latitude, 
        position.longitude
      );
      
      cafes.value = fetchedCafes;

    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
