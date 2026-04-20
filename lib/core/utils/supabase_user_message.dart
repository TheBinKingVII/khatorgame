import 'package:postgrest/postgrest.dart';

/// Maps [PostgrestException] to a short Indonesian message for SnackBars.
String supabaseUserMessage(Object error) {
  if (error is PostgrestException) {
    final String msg = error.message;
    final String? code = error.code;
    final String lower = msg.toLowerCase();

    if (code == '42501' ||
        lower.contains('row-level security') ||
        lower.contains('permission denied') ||
        lower.contains('new row violates row-level security')) {
      return 'Server menolak akses (RLS). Pastikan policy untuk tabel '
          'wishlists mengizinkan insert/delete/select dengan anon key, atau '
          'gunakan Edge Function.';
    }
    if (code == '23503') {
      return 'User tidak ditemukan di database (foreign key). Pastikan '
          'user_id di wishlists sama dengan id di tabel users.';
    }
    if (code == '23505') {
      return 'Deal ini sudah ada di wishlist.';
    }
    if (code == '42P01' || lower.contains('does not exist')) {
      return 'Tabel atau kolom tidak ada di Supabase. Periksa nama tabel '
          'wishlists dan kolomnya.';
    }
    if (msg.isNotEmpty) {
      return msg;
    }
    return 'Gagal menghubungi database${code != null ? ' ($code)' : ''}.';
  }

  return error
      .toString()
      .replaceFirst('Exception: ', '')
      .replaceFirst('PostgrestException: ', '');
}
