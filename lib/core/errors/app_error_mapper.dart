import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:postgrest/postgrest.dart';

import 'failures/failures.dart';

String mapErrorToUserMessage(
  Object error, {
  String fallbackMessage = 'Terjadi kesalahan. Silakan coba lagi.',
}) {
  if (error is Failure) {
    return error.message;
  }

  if (error is SocketException || error is TimeoutException) {
    return 'Jaringan Anda bermasalah. Periksa koneksi internet lalu coba lagi.';
  }

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.unknown:
        return 'Jaringan Anda bermasalah. Periksa koneksi internet lalu coba lagi.';
      case DioExceptionType.badResponse:
        return 'Layanan sedang bermasalah. Coba beberapa saat lagi.';
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return fallbackMessage;
    }
  }

  if (error is PostgrestException) {
    if (error.code == '23505') {
      return 'Data sudah pernah ditambahkan sebelumnya.';
    }
    if (error.code == '23503') {
      return 'Data akun tidak valid. Silakan login ulang.';
    }
    if (error.code == '42501') {
      return 'Anda tidak memiliki akses untuk aksi ini.';
    }
    return 'Layanan sedang bermasalah. Coba beberapa saat lagi.';
  }

  if (error is StateError) {
    return 'Sesi Anda berakhir. Silakan login kembali.';
  }

  final String message = error.toString().toLowerCase();
  if (message.contains('email belum terdaftar') ||
      message.contains('password salah') ||
      message.contains('akun tidak aktif')) {
    return 'Email atau password tidak sesuai.';
  }
  if (message.contains('email sudah digunakan')) {
    return 'Email sudah digunakan. Silakan pakai email lain.';
  }
  if (message.contains('biometrik belum diaktifkan')) {
    return 'Biometrik belum aktif di akun ini.';
  }
  if (message.contains('verifikasi biometrik')) {
    return 'Verifikasi biometrik gagal atau dibatalkan.';
  }

  return fallbackMessage;
}
