import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khatorgame/features/profile/domain/entities/profile_entity.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.profile,
    required this.onEditTap,
    required this.pendingAvatarPath,
    super.key,
  });

  final ProfileEntity profile;
  final VoidCallback onEditTap;
  final String? pendingAvatarPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: pendingAvatarPath != null
                ? FileImage(File(pendingAvatarPath!))
                : (profile.avatarUrl.isEmpty
                      ? null
                      : NetworkImage(profile.avatarUrl)),
            child: pendingAvatarPath == null && profile.avatarUrl.isEmpty
                ? const Icon(Icons.person_outline, size: 28)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEditTap,
          ),
        ],
      ),
    );
  }
}

