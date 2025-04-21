import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pack/auth/custom_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'core/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    final provider = Provider.of<ProfileProviderModel>(context, listen: false);
    final user = provider.user;

    if (user != null) {
      _nameController.text = user.name ;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? "Not provided" ;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<ProfileProviderModel>(context, listen: false);

    // First update profile picture if selected
    if (_profileImage != null) {
      await provider.updateProfilePicture(_profileImage!.path);
      if (provider.status == ProfileUpdateStatus.error) {
        _showErrorSnackBar(provider.errorMessage ?? 'Failed to update profile picture');
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // Then update profile details
    await provider.updateUserProfile(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (provider.status == ProfileUpdateStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      provider.resetStatus();
    } else if (provider.status == ProfileUpdateStatus.error) {
      _showErrorSnackBar(provider.errorMessage ?? 'Failed to update profile');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProviderModel>(context);
    final user = provider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!) as ImageProvider
                          : (user.profileImage != null
                          ? NetworkImage(user.profileImage!) as ImageProvider
                          : const AssetImage('assets/images/default_avatar.png') as ImageProvider),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AuthTextField(
                controller: _nameController,
                label: 'Full Name',
                prefixIcon: Icon(Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _phoneController,
                label: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AuthButton(
                 onPressed:()=> _isLoading ? null : _updateProfile,
                isLoading: _isLoading, text: 'Update Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}