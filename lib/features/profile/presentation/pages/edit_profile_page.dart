import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khatorgame/features/profile/presentation/controllers/profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileController _controller = Get.find<ProfileController>();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = _controller.profile.value;
    _nameController.text = profile?.fullName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = _controller.profile.value;
      if (profile == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Center(
              child: Stack(
                children: <Widget>[
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: profile.avatarUrl.isEmpty
                        ? null
                        : NetworkImage(profile.avatarUrl),
                    child: profile.avatarUrl.isEmpty
                        ? const Icon(Icons.person_outline, size: 42)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: FilledButton(
                      onPressed: _controller.isSaving.value
                          ? null
                          : () async {
                              final bool changed =
                                  await _controller.pickAndUploadAvatar();
                              if (changed && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Foto profil diperbarui'),
                                  ),
                                );
                              }
                            },
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                      ),
                      child: const Icon(Icons.photo_camera_outlined, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              child: Text(
                profile.email,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _controller.isSaving.value
                  ? null
                  : () async {
                      await _controller.saveFullName(_nameController.text);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil diperbarui')),
                      );
                      Navigator.of(context).pop();
                    },
              child: _controller.isSaving.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      );
    });
  }
}

