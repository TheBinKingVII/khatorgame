import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:postgrest/postgrest.dart';

import 'failures/failures.dart';

String mapErrorToUserMessage(
  Object error, {
  String fallbackMessage = 'An error occurred. Please try again.',
}) {
  if (error is Failure) {
    return error.message;
  }

  if (error is SocketException || error is TimeoutException) {
    return 'There is network problem. Please check your internet connection and try again.';
  }

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.unknown:
        return 'There is network problem. Please check your internet connection and try again.';
      case DioExceptionType.badResponse:
        return 'Server is having some problems. Please try again later.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return fallbackMessage;
    }
  }

  if (error is PostgrestException) {
    if (error.code == '23505') {
      return 'Data already added before.';
    }
    if (error.code == '23503') {
      return 'Invalid account data. Please log in again.';
    }
    if (error.code == '42501') {
      return 'You do not have permission to perform this action.';
    }
    return 'Server is having some problems. Please try again later.';
  }

  if (error is StateError) {
    return 'Session has expired. Please log in again.';
  }

  final String message = error.toString().toLowerCase();
  if (message.contains('email not registered') ||
      message.contains('wrong password') ||
      message.contains('email belum terdaftar') ||
      message.contains('password salah')) {
    return 'Your username or password is incorrect.';
  }
  if (message.contains('account is not active') ||
      message.contains('akun tidak aktif')) {
    return 'Your account is inactive.';
  }
  if (message.contains('email is already used') ||
      message.contains('email sudah digunakan')) {
    return 'Email is already used. Please use another email.';
  }
  if (message.contains('biometric not activated')) {
    return 'Biometric is not activated in this account.';
  }
  if (message.contains('biometric verification')) {
    return 'Biometric verification failed or cancelled.';
  }

  return fallbackMessage;
}
