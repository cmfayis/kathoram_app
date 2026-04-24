import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../local_storage/shared_pref.dart';
import '../../../../routes/custom_navigator.dart';
import '../../../../routes/route_path.dart';
import '../../../../utils/enum.dart';
import '../../core/app_colors.dart';
import '../model/login_response_model.dart';
import '../model/signup_response_model.dart';
import '../model/user_profile_model.dart';
import '../repository/auth_repository.dart';

class AuthController extends GetxController {
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupAgeController = TextEditingController();
  final signupLanguageController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();

  final isTermsAgreed = false.obs;
  final isLoading = false.obs;
  final apiCallStatus = ApiCallStatus.holding.obs;

  final userProfile = Rxn<UserProfileData>();
  final selectedProfileImagePath = RxnString();

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    if (MySharedPref.getLoggedInStatus()) {
      checkIsLogin();
    }
  }

  Future<void> login() async {
    if (loginEmailController.text.trim().isEmpty ||
        loginPasswordController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all fields');
      return;
    }

    try {
      isLoading.value = true;
      apiCallStatus.value = ApiCallStatus.loading;

      final payload = {
        'email': loginEmailController.text.trim(),
        'password': loginPasswordController.text.trim(),
      };

      final response = await AuthRepository.login(payload);

      if (response.success && response.data != null) {
        final loginData = LoginResponseData.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (loginData.accessToken.isEmpty) {
          throw 'Access token not found in response';
        }

        await MySharedPref.setAuthToken(loginData.accessToken);
        await MySharedPref.setLoggedInStatus(true);
        await MySharedPref.setUserEmail(loginEmailController.text.trim());

        apiCallStatus.value = ApiCallStatus.success;
        Fluttertoast.showToast(msg: response.message);
        CustomNavigator.pushCompleteReplacement(RoutePath.bottomNav);
      } else {
        apiCallStatus.value = ApiCallStatus.error;
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      apiCallStatus.value = ApiCallStatus.error;
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    if (signupNameController.text.trim().isEmpty ||
        signupEmailController.text.trim().isEmpty ||
        signupAgeController.text.trim().isEmpty ||
        signupLanguageController.text.trim().isEmpty ||
        signupPasswordController.text.trim().isEmpty ||
        signupConfirmPasswordController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill all fields');
      return;
    }

    if (signupPasswordController.text.trim() !=
        signupConfirmPasswordController.text.trim()) {
      Fluttertoast.showToast(msg: 'Passwords do not match');
      return;
    }

    if (!isTermsAgreed.value) {
      Fluttertoast.showToast(msg: 'Please accept terms and conditions');
      return;
    }

    final age = int.tryParse(signupAgeController.text.trim());
    if (age == null || age <= 0) {
      Fluttertoast.showToast(msg: 'Please enter valid age');
      return;
    }

    try {
      isLoading.value = true;
      apiCallStatus.value = ApiCallStatus.loading;

      final payload = {
        'name': signupNameController.text.trim(),
        'email': signupEmailController.text.trim(),
        'password': signupPasswordController.text.trim(),
        'age': age,
        'lauguage': signupLanguageController.text.trim(),
        'isTermsAgreed': isTermsAgreed.value,
      };

      final response = await AuthRepository.signup(payload);

      if (response.success && response.data != null) {
        final signupData = SignupResponseData.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (signupData.accessToken.isEmpty) {
          throw 'Access token not found in response';
        }

        await MySharedPref.setAuthToken(signupData.accessToken);
        await MySharedPref.setLoggedInStatus(true);
        await MySharedPref.setUserEmail(
          signupData.email ?? signupEmailController.text.trim(),
        );

        apiCallStatus.value = ApiCallStatus.success;
        Fluttertoast.showToast(msg: response.message);

        CustomNavigator.pushCompleteReplacement(RoutePath.uploadProfilePicture);
      } else {
        apiCallStatus.value = ApiCallStatus.error;
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      apiCallStatus.value = ApiCallStatus.error;
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkIsLogin() async {
    try {
      final response = await AuthRepository.isLogin();

      if (response.success && response.data != null) {
        final Map<String, dynamic> dataMap =
            response.data as Map<String, dynamic>;
        final Map<String, dynamic> userJson =
            (dataMap['user'] is Map<String, dynamic>)
            ? dataMap['user'] as Map<String, dynamic>
            : dataMap;
        userProfile.value = UserProfileData.fromJson(userJson);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      final response = await AuthRepository.logout();
      if (response.success) {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
      await _clearSessionAndNavigate();
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      final response = await AuthRepository.deleteAccount();

      if (response.success) {
        Fluttertoast.showToast(msg: response.message);
        await _clearSessionAndNavigate();
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickProfileImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    selectedProfileImagePath.value = image.path;
  }

  Future<void> uploadProfileImageAndUpdate() async {
    final imagePath = selectedProfileImagePath.value;
    if (imagePath == null || imagePath.isEmpty) {
      Fluttertoast.showToast(msg: 'Please upload profile picture');
      return;
    }

    try {
      isLoading.value = true;

      final file = File(imagePath);
      final fileName = file.path.split(RegExp(r'[/\\]')).last;
      final fileType = getMimeType(file.path);

      final uploadUrlResponse = await AuthRepository.getUploadUrl(
        fileName: fileName,
        fileType: fileType,
      );
      if (!(uploadUrlResponse.success ||
          uploadUrlResponse.responseCode == 200)) {
        Fluttertoast.showToast(msg: uploadUrlResponse.message);
        return;
      }

      final uploadUrl = _extractUploadedFileReference(
        uploadUrlResponse.data,
        keys: const ['uploadUrl'],
      );
      final fileUrl = _extractUploadedFileReference(
        uploadUrlResponse.data,
        keys: const ['fileUrl', 'url', 'path', 'location', 'profileImage'],
      );

      if (uploadUrl == null ||
          uploadUrl.isEmpty ||
          fileUrl == null ||
          fileUrl.isEmpty) {
        Fluttertoast.showToast(msg: 'Unable to read upload url response');
        return;
      }

      final bytes = await file.readAsBytes();
      final uploadToStorageResponse = await Dio().put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {'Content-Type': fileType},
          validateStatus: (status) =>
              status != null && status >= 200 && status < 300,
        ),
      );

      if (uploadToStorageResponse.statusCode != 200 &&
          uploadToStorageResponse.statusCode != 201) {
        Fluttertoast.showToast(msg: 'Image upload failed');
        return;
      }

      final updateResponse = await AuthRepository.updateProfile({
        'profileImage': fileUrl,
      });

      if (updateResponse.success) {
        Fluttertoast.showToast(msg: updateResponse.message);
        await checkIsLogin();
        CustomNavigator.pushCompleteReplacement(RoutePath.approval);
      } else {
        Fluttertoast.showToast(msg: updateResponse.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String? _extractUploadedFileReference(
    dynamic data, {
    List<String> keys = const [
      'url',
      'fileUrl',
      'path',
      'location',
      'profileImage',
    ],
  }) {
    if (data is String && data.isNotEmpty) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final candidates = keys.map((key) => data[key]).toList();

      final fromTopLevel = candidates.firstWhereOrNull(
        (element) => element is String && element.toString().isNotEmpty,
      );
      if (fromTopLevel is String) return fromTopLevel;

      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedCandidates = keys.map((key) => nestedData[key]).toList();
        final fromNested = nestedCandidates.firstWhereOrNull(
          (element) => element is String && element.toString().isNotEmpty,
        );
        if (fromNested is String) return fromNested;
      }
    }

    return null;
  }

  Future<void> skipProfileUpload() async {
    CustomNavigator.pushCompleteReplacement(RoutePath.approval);
  }

  Future<void> _clearSessionAndNavigate() async {
    await MySharedPref.clear();
    Get.offAllNamed(RoutePath.signIn);
  }

  static void showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  title.toLowerCase().contains('delete')
                      ? Icons.delete_outline_rounded
                      : Icons.logout_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void clearLoginFields() {
    loginEmailController.clear();
    loginPasswordController.clear();
  }

  void clearSignupFields() {
    signupNameController.clear();
    signupEmailController.clear();
    signupAgeController.clear();
    signupLanguageController.clear();
    signupPasswordController.clear();
    signupConfirmPasswordController.clear();
    isTermsAgreed.value = false;
  }

  String getMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
