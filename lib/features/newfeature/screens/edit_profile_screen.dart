import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/controller/auth_controller.dart';
import '../auth/model/user_profile_model.dart';
import '../core/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  Worker? _profileWorker;
  bool _hasPrefilled = false;

  @override
  void initState() {
    super.initState();

    // If we already have a profile cached, prefill immediately.
    if (authController.userProfile.value != null) {
      authController.prefillEditProfileFromCache();
      _hasPrefilled = true;
    }

    // Watch for the first non-null profile arrival and prefill once —
    // this covers the race where the user lands here before isLogin
    // has finished resolving. We dispose after the first prefill so a
    // later refresh can't clobber the user's in-progress edits.
    _profileWorker = ever<UserProfileData?>(
      authController.userProfile,
      (profile) {
        if (!_hasPrefilled && profile != null) {
          authController.prefillEditProfileFromCache();
          _hasPrefilled = true;
          _profileWorker?.dispose();
          _profileWorker = null;
        }
      },
    );

    // Always trigger a refresh so the listener has something to fire on
    // even when the cache was empty on entry.
    authController.checkIsLogin();
  }

  @override
  void dispose() {
    _profileWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildAvatar(),
            const SizedBox(height: 35),
            CustomTextField(
              label: 'Name',
              hint: 'Enter your name',
              controller: authController.editNameController,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Age',
              hint: 'Enter Age here',
              controller: authController.editAgeController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Language',
              hint: 'Malayalam / English / Hindi',
              controller: authController.editLanguageController,
            ),
            const SizedBox(height: 40),
            Obx(
              () => CustomButton(
                text: authController.isUpdatingProfile.value
                    ? 'Saving...'
                    : 'Save Changes',
                onPressed: authController.isUpdatingProfile.value
                    ? () {}
                    : authController.saveProfileChanges,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Obx(() {
      final localPath = authController.editProfileImagePath.value;
      final remoteUrl = authController.userProfile.value?.profileImage ?? '';

      ImageProvider? imageProvider;
      if (localPath != null && localPath.isNotEmpty) {
        imageProvider = FileImage(File(localPath));
      } else if (remoteUrl.isNotEmpty) {
        imageProvider = NetworkImage(remoteUrl);
      }

      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.backgroundGrey,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 4,
            child: GestureDetector(
              onTap: authController.pickEditProfileImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
