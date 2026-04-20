import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:khatorgame/core/services/session_service.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FallingItem {
  final String emoji;
  double x;
  double y;
  final bool isBomb;

  FallingItem({
    required this.emoji,
    required this.x,
    required this.y,
    this.isBomb = false,
  });
}

class MinigamesPage extends StatefulWidget {
  const MinigamesPage({super.key});

  @override
  State<MinigamesPage> createState() => _MinigamesPageState();
}

class _MinigamesPageState extends State<MinigamesPage> {
  // Supabase instance
  final _supabase = Supabase.instance.client;

  // Sensor streams
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  StreamSubscription<dynamic>? _proximitySubscription;

  Timer? _gameLoopTimer;
  Timer? _spawnTimer;

  int _score = 0;
  double _rawAccelX = 0.0;
  double _basketX = 0.0;
  final List<FallingItem> _items = [];
  final Random _random = Random();

  bool _isGameOver = false;
  bool _gameStarted = false; // Flag status game
  bool _hasClaimedToday = false; // Flag limit harian
  bool _isClaiming = false; // Flag loading saat ambil voucher dari DB
  List<String> _myVouchers = [];

  // Scoring Target
  final int _targetScore = 200; // Target testing (ganti ke 2000 nanti)
  
  // Fitur Magnet
  bool _isMagnetActive = false;
  bool _canShake = true;
  
  final List<String> _goodEmojis = ['💻', '🖥️', '🖱️', '🎮', '🎧'];

  @override
  void initState() {
    super.initState();
    _loadGameData();
    _initSensors();
  }

  // Load data limit harian dan daftar voucher dari storage
  // (Nanti bisa diubah tarik dari DB juga, tapi buat sekarang kita pake shared_prefs buat limitnya)
  Future<void> _loadGameData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastClaim = prefs.getString('last_voucher_claim_date') ?? "";
    
    setState(() {
      _hasClaimedToday = (lastClaim == today);
      _myVouchers = prefs.getStringList('collected_vouchers') ?? [];
    });
  }

  // Ambil voucher random dari DB yang user_id nya null
  Future<void> _claimVoucherFromDatabase() async {
    setState(() => _isClaiming = true);

    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) throw "User tidak terdeteksi (Login dulu gih)";

      // 1. Cari 1 voucher yang belum dimiliki siapapun
      final response = await _supabase
          .from('vouchers')
          .select()
          .isFilter('user_id', null)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        throw "Waduh, stok voucher lagi abis bray! Hubungi admin.";
      }

      final voucherId = response['id'];
      final voucherCode = response['code'];

      // 2. Tandai voucher ini milik kita
      await _supabase
          .from('vouchers')
          .update({'user_id': currentUserId})
          .eq('id', voucherId);

      // 3. Simpan catatan lokal dan update status harian
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      _myVouchers.add(voucherCode);
      await prefs.setStringList('collected_vouchers', _myVouchers);
      await prefs.setString('last_voucher_claim_date', today);

      if (mounted) {
        setState(() {
          _hasClaimedToday = true;
          _isClaiming = false;
        });
        _showSuccessWinDialog(voucherCode);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isClaiming = false);
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[900],
        title: const Text('ERROR BRAY', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _items.clear();
      _isGameOver = false;
      _gameStarted = true;
    });

    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_isGameOver) return;
      _updateGame();
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_isGameOver) return;
      _spawnItem();
    });
  }

  void _spawnItem() {
    double bombChance = (0.2 + (_score / 2000)).clamp(0.2, 0.45);
    bool isBomb = _random.nextDouble() < bombChance;
    String emoji = isBomb ? '💣' : _goodEmojis[_random.nextInt(_goodEmojis.length)];

    setState(() {
      _items.add(FallingItem(
        emoji: emoji,
        x: (_random.nextDouble() * 2) - 1,
        y: -1.0,
        isBomb: isBomb,
      ));
    });
  }

  void _updateGame() {
    if (!mounted || !_gameStarted) return;
    
    double targetBasketX = -(_rawAccelX / 4.0).clamp(-1.0, 1.0);
    _basketX += (targetBasketX - _basketX) * 0.1; 

    setState(() {
      for (int i = _items.length - 1; i >= 0; i--) {
        int level = _score ~/ 200; 
        double speedFactor = 1.0 + (level * 0.3);
        
        if (_isMagnetActive && !_items[i].isBomb) {
           _items[i].x += (_basketX - _items[i].x) * 0.15;
           _items[i].y += 0.02 * speedFactor;
        } else {
          _items[i].y += 0.0075 * speedFactor; 
        }

        if (_items[i].y >= 0.8 && _items[i].y <= 1.0) {
          double distance = (_items[i].x - _basketX).abs();
          if (distance < 0.2) {
            if (_items[i].isBomb) {
              if (_isMagnetActive) {
                _items.removeAt(i);
                continue; 
              }
              _gameOver();
            } else {
              _score += _isMagnetActive ? 20 : 10;
              if (_score >= _targetScore) {
                _gameWin();
              }
            }
            _items.removeAt(i);
          }
        } else if (_items[i].y > 1.2) {
          _items.removeAt(i);
        }
      }
    });
  }

  void _gameOver() {
    _isGameOver = true;
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('GAME OVER!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Yahh kamu kena bom! Skor terakhir: $_score\nAyo coba lagi bray!',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('COBA LAGI', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _gameStarted = false);
            },
            child: const Text('MENU', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _gameWin() {
    _isGameOver = true;
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    
    // Panggil fungsi klaim dari database
    _claimVoucherFromDatabase();
  }

  void _showSuccessWinDialog(String voucherCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('MENANG! 🏆', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selamat! Kamu berhasil mendapatkan Voucher Steam Wallet harian!',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
              child: Text(voucherCode,
                  style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            const Text('Voucher sudah tersimpan otomatis di database.',
                style: TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _gameStarted = false);
            },
            child: const Text('MANTAP!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk reset data (kita minta konteks dialognya biar gak salah tutup)
  Future<void> _resetGameData(BuildContext dialogContext) async {
    try {
      // Tutup dialognya pake konteks dialog itu sendiri
      Navigator.of(dialogContext).pop();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('collected_vouchers');
      await prefs.remove('last_voucher_claim_date');
      await _loadGameData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil di-reset bray!')),
        );
      }
    } catch (e) {
      debugPrint("Gagal reset data: $e");
    }
  }

  // Tampilkan daftar semua voucher yang pernah didapat
  void _showInventoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C3E),
        title: const Text('Koleksi Voucher Kamu', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: _myVouchers.isEmpty
              ? const Text('Belum ada voucher bray. Main dulu!', style: TextStyle(color: Colors.white54))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _myVouchers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_myVouchers[index], style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                          const Icon(Icons.copy, size: 16, color: Colors.white24),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => _resetGameData(context), // <--- Pakai konteks dialog ini
            child: const Text('RESET DATA', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('TUTUP', style: TextStyle(color: Colors.blueAccent))),
        ],
      ),
    );
  }

  void _initSensors() {
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted || _isGameOver) return;
      _rawAccelX = event.x;
    });

    _proximitySubscription = ProximitySensor.events.listen((int event) {
      if (!mounted || _isGameOver || !_canShake || !_gameStarted) return;
      if (event > 0) {
        setState(() {
          _isMagnetActive = true;
          _canShake = false;
          _items.removeWhere((item) => item.isBomb);
        });
        Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _isMagnetActive = false);
          Timer(const Duration(seconds: 8), () {
            if (mounted) setState(() => _canShake = true);
          });
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🧲 SUPER MAGNET AKTIF!'), backgroundColor: Colors.blueAccent),
        );
      }
    });
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _proximitySubscription?.cancel();
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Gudang Gear Khator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _gameStarted 
          ? _buildGameUI(key: const ValueKey('game')) 
          : _buildLobbyUI(key: const ValueKey('lobby')),
      ),
    );
  }

  // === UI LOBBY (MENU AWAL) ===
  Widget _buildLobbyUI({Key? key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videogame_asset, size: 80, color: Colors.amber),
          const SizedBox(height: 10),
          const Text('Minigame Hadiah Steam',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _buildInstructionItem(Icons.edgesensor_low, 'Miringkan HP', 'Gerakkan keranjang ke kiri/kanan.'),
          _buildInstructionItem(Icons.pan_tool, 'Tutup Sensor Atas', 'Aktifkan Magnet & Shield (3 detik).'),
          _buildInstructionItem(Icons.star, 'Kumpulkan $_targetScore Poin', 'Dapatkan 1 Voucher Steam per hari.'),
          const Spacer(),
          if (_hasClaimedToday)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Text('✅ Hadiah Sudah Diambil!\nBalik lagi besok ya bro.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
            )
          else
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('MULAI BERMAIN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Voucher di Inventory: ${_myVouchers.length}', style: const TextStyle(color: Colors.white54)),
              const SizedBox(width: 10),
              if (_myVouchers.isNotEmpty)
                GestureDetector(
                  onTap: _showInventoryDialog,
                  child: const Text('LIHAT SEMUA', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.underline)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.blueAccent, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // === UI GAMEPLAY ===
  Widget _buildGameUI({Key? key}) {
    return Column(
      key: key,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
                child: Text('Poin: $_score',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text('🎯 Target: $_targetScore', style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                   Text('⚡ Magnet: ${_canShake ? 'READY' : 'COOLDOWN'}', style: TextStyle(color: _canShake ? Colors.blueAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(border: _isMagnetActive ? Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 4) : null),
            child: ClipRRect(
              child: Stack(
                children: [
                  ..._items.map((item) => Align(
                        alignment: Alignment(item.x, item.y),
                        child: Text(item.emoji, style: const TextStyle(fontSize: 40)),
                      )),
                  Align(
                    alignment: Alignment(_basketX, 0.9),
                    child: Container(
                      width: 90, height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: const Center(child: Text('🛒', style: TextStyle(fontSize: 28))),
                    ),
                  ),
                  if (_isClaiming)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.amber),
                            SizedBox(height: 15),
                            Text('Menghubungi Gudang Gear...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
