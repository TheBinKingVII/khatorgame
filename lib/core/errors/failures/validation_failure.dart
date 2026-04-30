import 'failure.dart';

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'The data sent is not valid.']);
}
