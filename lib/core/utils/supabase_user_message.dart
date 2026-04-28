import 'package:khatorgame/core/errors/app_error_mapper.dart';

/// Maps [PostgrestException] to a short Indonesian message for SnackBars.
String supabaseUserMessage(Object error) {
  return mapErrorToUserMessage(error);
}
