import 'failure.dart';

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network is having some problems.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server is having some problems.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data cannot be accessed.']);
}
