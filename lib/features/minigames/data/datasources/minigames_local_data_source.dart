import 'package:shared_preferences/shared_preferences.dart';

abstract class MinigamesLocalDataSource {
  Future<List<String>> getCollectedVouchers();
  Future<void> saveCollectedVoucher(String code);
  Future<bool> hasClaimedToday();
  Future<void> setHasClaimedToday();
  Future<void> resetData();
}

class MinigamesLocalDataSourceImpl implements MinigamesLocalDataSource {
  static const String _vouchersKey = 'collected_vouchers';
  static const String _lastClaimDateKey = 'last_voucher_claim_date';

  @override
  Future<List<String>> getCollectedVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_vouchersKey) ?? [];
  }

  @override
  Future<void> saveCollectedVoucher(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> vouchers = prefs.getStringList(_vouchersKey) ?? [];
    vouchers.add(code);
    await prefs.setStringList(_vouchersKey, vouchers);
  }

  @override
  Future<bool> hasClaimedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().split('T')[0];
    final String lastClaim = prefs.getString(_lastClaimDateKey) ?? "";
    return lastClaim == today;
  }

  @override
  Future<void> setHasClaimedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(_lastClaimDateKey, today);
  }

  // Buat testing
  // @override
  // Future<bool> hasClaimedToday() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final String lastClaim = prefs.getString(_lastClaimDateKey) ?? "";
    
  //   if (lastClaim.isEmpty) return false;

  //   final lastClaimTime = DateTime.parse(lastClaim);
  //   final now = DateTime.now();
    
  //   // Reset setiap 1 menit
  //   final difference = now.difference(lastClaimTime).inMinutes;
  //   return difference < 1; // Kalau baru 0 menit, berarti sudah klaim. Kalau sudah 1 menit, reset.
  // }

  // @override
  // Future<void> setHasClaimedToday() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(_lastClaimDateKey, DateTime.now().toIso8601String());
  // }


  @override
  Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vouchersKey);
    await prefs.remove(_lastClaimDateKey);
  }
}
