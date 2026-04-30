import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/core/services/biometric_auth_service.dart';
import 'package:khatorgame/features/profile/presentation/controllers/profile_controller.dart';

class BiometricSettingsPage extends StatefulWidget {
  const BiometricSettingsPage({super.key});

  @override
  State<BiometricSettingsPage> createState() => _BiometricSettingsPageState();
}

class _BiometricSettingsPageState extends State<BiometricSettingsPage> {
  final ProfileController _controller = Get.find<ProfileController>();
  final BiometricAuthService _biometricService = BiometricAuthService.instance;

  bool _checkingSupport = true;
  bool _isSupported = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSupportStatus();
  }

  Future<void> _loadSupportStatus() async {
    final bool supported = await _biometricService.canUseBiometric();
    if (!mounted) return;
    setState(() {
      _isSupported = supported;
      _checkingSupport = false;
    });
  }

  Future<void> _onChanged(bool value) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });
    final bool success = await _controller.setBiometricEnabled(value);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (value
                    ? 'Biometrik berhasil diaktifkan'
                    : 'Biometrik dinonaktifkan')
              : (_controller.biometricStatusMessage.value ??
                    'Failed to enable biometrics'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Login'),
        automaticallyImplyLeading: false,
      ),
      body: _checkingSupport
          ? const Center(child: CircularProgressIndicator())
          : Obx(() {
              final bool isEnabled = _controller.isBiometricEnabled.value;
              final bool switchEnabled =
                  _isSupported &&
                  !_isSaving &&
                  _controller.profile.value != null &&
                  !_controller.isLoading.value;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Card(
                    child: SwitchListTile(
                      value: isEnabled,
                      onChanged: switchEnabled ? _onChanged : null,
                      title: const Text('Enable Biometric Login'),
                      subtitle: Text(
                        _isSupported
                            ? 'Gunakan sidik jari / face unlock saat login'
                            : 'Perangkat tidak mendukung biometrik atau belum dikonfigurasi',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_controller.isLoading.value)
                    const Text(
                      'Menunggu data profil dimuat sebelum aktivasi biometrik.',
                    ),
                  if (!_controller.isLoading.value &&
                      _controller.profile.value == null)
                    const Text(
                      'Profil belum tersedia. Buka ulang halaman setelah profil berhasil dimuat.',
                    ),
                  if (_controller.biometricStatusMessage.value !=
                      null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(_controller.biometricStatusMessage.value!),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'Saat aktif, Anda bisa login lebih cepat dari halaman login tanpa memasukkan password.',
                  ),
                ],
              );
            }),
    );
  }
}
