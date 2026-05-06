import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/minigames_model.dart';

abstract class MinigamesRemoteDataSource {
  Future<VoucherModel> claimVoucher(String userId);
  Future<bool> checkVoucherAvailability();
}

class MinigamesRemoteDataSourceImpl implements MinigamesRemoteDataSource {
  MinigamesRemoteDataSourceImpl({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<VoucherModel> claimVoucher(String userId) async {
    // Cari 1 voucher yang belum dimiliki siapapun
    final response = await _client
        .from('vouchers')
        .select()
        .isFilter('user_id', null)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      throw Exception("Out of stock. Vouchers are currently unavailable.");
    }

    final voucher = VoucherModel.fromJson(response);

    // Tandai voucher ini milik user
    await _client
        .from('vouchers')
        .update({'user_id': userId})
        .eq('id', voucher.id);

    return voucher;
  }

  @override
  Future<bool> checkVoucherAvailability() async {
    final response = await _client
        .from('vouchers')
        .select('id')
        .isFilter('user_id', null)
        .limit(1)
        .maybeSingle();
    return response != null;
  }
}
