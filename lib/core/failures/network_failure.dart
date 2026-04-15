import 'base_failure.dart';

class NetworkFailure extends Failure {
  NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  ServerFailure([super.message = 'Server error']);
}

class CacheFailure extends Failure {
  CacheFailure([super.message = 'Cache error']);
}
