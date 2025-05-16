import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:my_ad/core/domain/data_store/data_store.dart';

import '../../../../../core/data/model/merchant/merchant_model.dart';

class ProfileHeader extends StatelessWidget {
  final MerchantModel profile;
  final VoidCallback onEdit;

  const ProfileHeader({super.key, required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    dev.log('Profile Header: ${profile.toJson()}');
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(top: 16, bottom: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.blue.shade50,
                backgroundImage:
                    profile.companyLogo != null &&
                            profile.companyLogo!.isNotEmpty
                        ? NetworkImage(profile.companyLogo!)
                        : null,
                child:
                    profile.companyLogo == null || profile.companyLogo!.isEmpty
                        ? Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.blue.shade300,
                        )
                        : null,
              ),
              const SizedBox(height: 14),
              Text(
                profile.username,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                profile.email,
                style: TextStyle(fontSize: 15, color: Colors.blueGrey.shade700),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blueAccent),
                ),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
