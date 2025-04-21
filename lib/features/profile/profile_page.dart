import 'package:flutter/material.dart';
import 'package:my_ad/core/data/model/model.dart';
import 'package:provider/provider.dart';

import 'core/profile_provider.dart';
import 'edit_profile_screen.dart';

class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: Consumer<ProfileProviderModel>(
        builder: (context, provider, _) {
          if (provider.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = provider.user!;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(user.profileImage!) as ImageProvider
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailItem(context, 'Name', user.name ),
                _buildDetailItem(context, 'Email', user.email),
                _buildDetailItem(context, 'Mobile Number', user.phoneNumber ?? 'Not set'),
                _buildDetailItem(context, 'Gender', user.metadata![UserMetadata.gender.name] ?? 'Not set'),
                // _buildDetailItem(
                //   context,
                //   'Birthday',
                //   user.birthday != null
                //       ? '${user.birthday!.day}/${user.birthday!.month}/${user.birthday!.year}'
                //       : 'Not set',
                //   canEdit: true,
                //   onEdit: () => _showBirthdayPicker(context, provider),
                // ),
                // _buildDetailItem(
                //   context,
                //   'Languages',
                //   user.languages != null && user.languages!.isNotEmpty
                //       ? user.languages!.join(', ')
                //       : 'Not set',
                //   canEdit: true,
                //   onEdit: () => _showLanguageSelector(context, provider),
                // ),
                _buildDetailItem(context, 'Marital Status', user.metadata![UserMetadata.maretialStatus.name] ?? 'Not set'),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(120, 48),
                        ),
                        child: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(120, 48),
                        ),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context,
      String label,
      String value,
      {bool canEdit = false, VoidCallback? onEdit}
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (canEdit && onEdit != null)
                TextButton(
                  onPressed: onEdit,
                  child: Text(
                    value == 'Not set' ? 'Add' : 'Edit',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _showBirthdayPicker(BuildContext context, ProfileProviderModel provider) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      // initialDate: provider.user?.birthday ?? DateTime.now(),
      initialDate:   DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      // Add birthday update logic
      provider.updateUserProfile(
        additionalData: {'birthday': pickedDate.toIso8601String()},
      );
    }
  }

  void _showLanguageSelector(BuildContext context, ProfileProviderModel provider) {
    final List<String> availableLanguages = [
      'English', 'Spanish', 'French', 'German', 'Hindi', 'Chinese', 'Japanese', 'Arabic'
    ];


    // final List<String> selectedLanguages =
    //     provider.user?.languages?.toList() ?? [];

    final List<String> selectedLanguages = availableLanguages;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Languages'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableLanguages.length,
                  itemBuilder: (context, index) {
                    final language = availableLanguages[index];
                    return CheckboxListTile(
                      title: Text(language),
                      value: selectedLanguages.contains(language),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedLanguages.add(language);
                          } else {
                            selectedLanguages.remove(language);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.updateUserProfile(
                      additionalData: {'languages': selectedLanguages},
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}