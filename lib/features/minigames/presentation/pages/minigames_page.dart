import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:khatorgame/features/minigames/presentation/controllers/minigames_controller.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:timezone/timezone.dart' as tz;

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
  // GetX Controller (Logic & State)
  final MinigamesController _controller = Get.find<MinigamesController>();

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

  // Scoring Target
  final int _targetScore = 200; // Target testing (ganti ke 2000 nanti)
  
  // Fitur Magnet
  bool _isMagnetActive = false;
  bool _canShake = true;
  
  final List<String> _goodEmojis = ['💻', '🖥️', '🖱️', '🎮', '🎧'];

  // Offline detection
  bool _isOffline = false;
  bool _isCheckingConn = false;

  @override
  void initState() {
    super.initState();
    _initSensors();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    if (!mounted) return;
    setState(() => _isCheckingConn = true);
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _isOffline = result.isEmpty || result[0].rawAddress.isEmpty;
          _isCheckingConn = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _isOffline = true; _isCheckingConn = false; });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[900],
        title: const Text('ERROR', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _startGame() {
    // Blokir jika offline
    if (_isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Koneksi terputus. Pastikan internet aktif untuk bermain!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
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
        backgroundColor: Theme.of(context).colorScheme.primary,
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

  void _gameWin() async {
    _isGameOver = true;
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    await _tryClaim();
  }

  // Method klaim yang bisa dipanggil ulang tanpa perlu stop game lagi
  Future<void> _tryClaim() async {
    if (!mounted) return;

    // Cek koneksi real-time sebelum klaim
    bool canConnect = false;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      canConnect = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      canConnect = false;
    }

    if (!mounted) return;

    if (!canConnect) {
      // Offline — tampilkan dialog ramah dengan tombol retry
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('Koneksi Terputus', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Selamat, kamu sudah menang! 🎉\n\nTapi koneksi internet terputus saat proses klaim voucher.\nHubungkan ke internet lalu coba klaim ulang.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _gameStarted = false);
              },
              child: Text('Ke Menu', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await _tryClaim(); // Coba klaim ulang tanpa restart game
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Online — lanjut klaim voucher
    final voucherCode = await _controller.claimVoucher();
    if (!mounted) return;
    if (voucherCode != null) {
      _showSuccessWinDialog(voucherCode);
    } else if (_controller.errorMessage.value.isNotEmpty) {
      _showErrorDialog(_controller.errorMessage.value);
      setState(() => _gameStarted = false);
    }
  }


  void _showSuccessWinDialog(String voucherCode) {
    final nowUtc = DateTime.now().toUtc();
    final timezones = {
      'WIB (Jakarta)': tz.getLocation('Asia/Jakarta'),
      'WITA (Makassar)': tz.getLocation('Asia/Makassar'),
      'WIT (Jayapura)': tz.getLocation('Asia/Jayapura'),
      'London (UK)': tz.getLocation('Europe/London'),
    };
    
    String selectedZone = 'WIB (Jakarta)';

    String formatTime(DateTime dt, tz.Location loc) {
      final tzd = tz.TZDateTime.from(dt, loc);
      return "${tzd.hour.toString().padLeft(2, '0')}:${tzd.minute.toString().padLeft(2, '0')}";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.green[800],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('MENANG! 🏆', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Selamat! Kamu berhasil mendapatkan Voucher Steam!',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(10)),
                  child: Text(voucherCode,
                      style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                const Text('Cek Konversi Waktu Klaim:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                        child: DropdownButton<String>(
                          value: selectedZone,
                          dropdownColor: Colors.green[900],
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          underline: const SizedBox(),
                          items: timezones.keys.map((String key) {
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Text(key, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setStateDialog(() {
                                selectedZone = newValue;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatTime(nowUtc, timezones[selectedZone]!),
                        style: const TextStyle(color: Colors.amber, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
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
          );
        }
      ),
    );
  }

  // Fungsi untuk reset data (kita minta konteks dialognya biar gak salah tutup)
  Future<void> _resetGameData(BuildContext dialogContext) async {
    try {
      // Tutup dialognya pake konteks dialog itu sendiri
      Navigator.of(dialogContext).pop();
      
      await _controller.resetTestingData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil di-reset bray!')),
        );
      }
    } catch (e) {
      debugPrint("Gagal reset data: $e");
    }
  }

  // Tampilkan daftar semua voucher yang pernah didapat beserta konversi waktunya
  void _showInventoryDialog() {
    String selectedZone = 'WIB (Jakarta)';
    int? copiedIndex;
    final Map<String, tz.Location> zoneOffsets = {
      'WIB (Jakarta)': tz.getLocation('Asia/Jakarta'),
      'WITA (Makassar)': tz.getLocation('Asia/Makassar'),
      'WIT (Jayapura)': tz.getLocation('Asia/Jayapura'),
      'London (UK)': tz.getLocation('Europe/London'),
    };

    String formatTime(DateTime utcTime, tz.Location loc) {
      final dt = tz.TZDateTime.from(utcTime, loc);
      final ymd = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
      final hms = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      return "$ymd - $hms";
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text('Vouchers', style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: double.maxFinite,
              // Kasih batasan max biar nggak overflow ke luar layar
              height: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                    child: DropdownButton<String>(
                      value: selectedZone,
                      dropdownColor: const Color(0xFF1A237E),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      underline: const SizedBox(),
                      items: zoneOffsets.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setStateDialog(() {
                            selectedZone = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Obx(() {
                      if (_controller.collectedVouchers.isEmpty) {
                        return const Center(
                          child: Text('Belum ada voucher bray. Main dulu!', style: TextStyle(color: Colors.white54)),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: _controller.collectedVouchers.length,
                        itemBuilder: (context, index) {
                          final item = _controller.collectedVouchers[index];
                          // Pecah string berformat "KODE#TIMESTAMP_UTC"
                          final parts = item.split('#');
                          final code = parts[0];
                          String timeDisplay = "Waktu klaim tidak tercatat (data lama)";
                          
                          if (parts.length > 1) {
                            final utcTime = DateTime.tryParse(parts[1]);
                            if (utcTime != null) {
                              timeDisplay = formatTime(utcTime, zoneOffsets[selectedZone]!);
                            }
                          }

                          return InkWell(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(text: code));
                              setStateDialog(() {
                                copiedIndex = index;
                              });
                              Future.delayed(const Duration(seconds: 2), () {
                                if (context.mounted) {
                                  setStateDialog(() {
                                    if (copiedIndex == index) copiedIndex = null;
                                  });
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: copiedIndex == index ? Colors.green[800] : Colors.black26, 
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          copiedIndex == index ? "Tersalin ke Clipboard! 📋" : code, 
                                          overflow: TextOverflow.ellipsis, 
                                          style: TextStyle(
                                            color: copiedIndex == index ? Colors.white : Colors.amber, 
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 16
                                          )
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        copiedIndex == index ? Icons.check_circle : Icons.copy, 
                                        size: 16, 
                                        color: copiedIndex == index ? Colors.white : Theme.of(context).colorScheme.background
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 12, color: Colors.white38),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(timeDisplay, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => _resetGameData(context), // <--- Pakai konteks dialog ini
                child: const Text('RESET DATA', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
              ),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('TUTUP', style: TextStyle(color: Colors.blueAccent))),
            ],
          );
        }
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
          SnackBar(content: const Text('🧲 SUPER MAGNET AKTIF!'), backgroundColor: Theme.of(context).colorScheme.primary),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Gudang Gear Khator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
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
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          const Icon(Icons.videogame_asset, size: 80, color: Colors.amber),
          const SizedBox(height: 10),
          const Text('Minigame Berhadiah',
              style: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _buildInstructionItem(Icons.edgesensor_low, 'Miringkan HP', 'Gerakkan keranjang ke kiri/kanan.'),
          _buildInstructionItem(Icons.pan_tool, 'Tutup Sensor Atas', 'Aktifkan Magnet & Shield (3 detik).'),
          _buildInstructionItem(Icons.star, 'Kumpulkan $_targetScore Poin', 'Dapatkan 1 Voucher Steam Wallet per hari.'),
          const SizedBox(height: 16),
          // Cek koneksi dulu
          if (_isCheckingConn)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(children: [
                CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text('Mengecek koneksi...', style: TextStyle(color: Colors.grey[600])),
              ]),
            )
          else if (_isOffline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.redAccent.shade100),
              ),
              child: Column(
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 44, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  const Text(
                    'Tidak Ada Koneksi Internet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Minigame membutuhkan internet untuk klaim voucher. Hubungkan ke jaringan lalu coba lagi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.red.shade400, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _checkConnectivity,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Coba Lagi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            )
          else
            Obx(() {
              if (_controller.hasClaimedToday.value) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Text('✅ Hadiah Sudah Diambil!\nBalik lagi besok ya',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                );
              } else {
                return SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('MULAI BERMAIN',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                );
              }
            }),
          const SizedBox(height: 30),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Voucher di Inventory: ${_controller.collectedVouchers.length}', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 10),
              if (_controller.collectedVouchers.isNotEmpty)
                GestureDetector(
                  onTap: _showInventoryDialog,
                  child: const Text('LIHAT SEMUA', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12, decoration: TextDecoration.underline)),
                ),
            ],
          )),
          const SizedBox(height: 16),
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
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
                child: Text('Poin: $_score',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text('🎯 Target: $_targetScore', style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                   Text('⚡ Magnet: ${_canShake ? 'READY' : 'COOLDOWN'}', style: TextStyle(color: _canShake ? Theme.of(context).colorScheme.primary : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(border: _isMagnetActive ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), width: 4) : null),
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
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: const Center(child: Text('🛒', style: TextStyle(fontSize: 28))),
                    ),
                  ),
                  Obx(() {
                    if (_controller.isClaiming.value) {
                      return Container(
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
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

