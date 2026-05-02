import 'package:flutter/material.dart';

class AdvicePage extends StatelessWidget {
  const AdvicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Text(
          'Advice',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Saran & Masukan\nTeknologi Pemrograman Mobile',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
            _buildCard(
              context,
              name: 'Khatama',
              role: 'Korban TPM 1',
              avatarIcon: Icons.person,
              content:
                  'Semoga teori di kelas bisa lebih banyak disampaikan ke mahasiswa.',
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              name: 'Bintoro',
              role: 'Korban TPM 2',
              avatarIcon: Icons.person_outline,
              content:
                  'Surat Terbuka untuk Pak Bagus, Semoga Mobile kedepannya lebih brutal dari sekarang. Tolong siksa angkatan selanjutnya. Oh ya prodi satunya juga tolong disiksa.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String name,
    required String role,
    required IconData avatarIcon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                radius: 24,
                child: Icon(
                  avatarIcon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.amber,
                size: 36,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"$content"',
            style: const TextStyle(
              height: 1.6,
              fontStyle: FontStyle.italic,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
