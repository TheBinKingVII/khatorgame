import 'failure.dart';

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Jaringan Anda bermasalah.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Layanan sedang bermasalah.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Data lokal tidak dapat diakses.']);
}
