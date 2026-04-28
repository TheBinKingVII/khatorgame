import 'failure.dart';

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Data yang dikirim belum valid.']);
}
