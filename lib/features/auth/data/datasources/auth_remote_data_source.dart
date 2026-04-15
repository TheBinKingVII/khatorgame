import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic>? data = await _client
        .from('users')
        .select('id,email,full_name,password_hash,is_active')
        .eq('email', email.toLowerCase().trim())
        .maybeSingle();

    if (data == null) {
      throw Exception('Email belum terdaftar');
    }

    if ((data['is_active'] as bool?) == false) {
      throw Exception('Akun tidak aktif');
    }

    final String incomingHash = _hashPassword(password);
    if (incomingHash != data['password_hash']) {
      throw Exception('Password salah');
    }

    return AuthModel.fromMap(data);
  }

  Future<AuthModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final String normalizedEmail = email.toLowerCase().trim();
    final String hash = _hashPassword(password);

    try {
      final Map<String, dynamic> data = await _client
          .from('users')
          .insert(<String, dynamic>{
            'full_name': fullName.trim(),
            'email': normalizedEmail,
            'password_hash': hash,
          })
          .select('id,email,full_name')
          .single();

      return AuthModel.fromMap(data);
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw Exception('Email sudah digunakan');
      }
      throw Exception(error.message);
    }
  }

  String _hashPassword(String input) {
    final List<int> bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
