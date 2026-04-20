import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getOrCreateProfile({
    required String userId,
    required String userEmail,
  });

  Future<ProfileModel> updateProfile({
    required String userId,
    required Map<String, dynamic> values,
  });

  Future<void> updateUserFullName({
    required String userId,
    required String fullName,
  });

  Future<String> uploadAvatarFile({
    required String userId,
    required String filePath,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static const String _table = 'profiles';
  static const String _avatarBucket = 'avatars';

  @override
  Future<ProfileModel> getOrCreateProfile({
    required String userId,
    required String userEmail,
  }) async {
    final Map<String, dynamic>? userRow = await _client
        .from('users')
        .select('email,full_name')
        .eq('id', userId)
        .maybeSingle();

    final String effectiveEmail =
        (userRow?['email'] as String?)?.trim().isNotEmpty == true
        ? (userRow!['email'] as String)
        : userEmail;
    final String effectiveFullName = (userRow?['full_name'] as String?) ?? '';

    await _client.from(_table).upsert(<String, dynamic>{
      'id': userId,
      'email': effectiveEmail,
      'full_name': effectiveFullName,
    });

    final Map<String, dynamic> row = await _client
        .from(_table)
        .select()
        .eq('id', userId)
        .single();

    return ProfileModel.fromMap(row);
  }

  @override
  Future<ProfileModel> updateProfile({
    required String userId,
    required Map<String, dynamic> values,
  }) async {
    final Map<String, dynamic> row = await _client
        .from(_table)
        .update(values)
        .eq('id', userId)
        .select()
        .single();
    return ProfileModel.fromMap(row);
  }

  @override
  Future<void> updateUserFullName({
    required String userId,
    required String fullName,
  }) async {
    await _client.from('users').update(<String, dynamic>{
      'full_name': fullName,
    }).eq('id', userId);
  }

  @override
  Future<String> uploadAvatarFile({
    required String userId,
    required String filePath,
  }) async {
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(filePath)}';
    final String objectPath = '$userId/$fileName';

    await _client.storage.from(_avatarBucket).upload(
          objectPath,
          File(filePath),
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(_avatarBucket).getPublicUrl(objectPath);
  }
}

