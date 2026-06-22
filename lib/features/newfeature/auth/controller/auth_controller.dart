import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../local_storage/shared_pref.dart';
import '../../../../routes/custom_navigator.dart';
import '../../../../routes/route_path.dart';
import '../../../../services/call_permission_service.dart';
import '../../../../services/socket_service.dart';
import '../../../../services/zego_call_service.dart';
import '../../../../utils/enum.dart';
import '../../core/app_colors.dart';
import '../model/call_history_model.dart';
import '../model/login_response_model.dart';
import '../model/recent_call_model.dart';
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

  // Edit Profile fields
  final editNameController = TextEditingController();
  final editAgeController = TextEditingController();
  final editLanguageController = TextEditingController();
  final editProfileImagePath = RxnString();
  final isUpdatingProfile = false.obs;

  // Online/Offline status
  final isOnlineStatus = false.obs;

  // Call History
  final callHistoryList = <CallHistoryItem>[].obs;
  final callHistoryPage = 1.obs;
  final isLoadingCallHistory = false.obs;
  final hasMoreCallHistory = true.obs;

  // Recent Calls (home screen)
  final recentCallsList = <RecentCallItem>[].obs;
  final recentCallsPage = 1.obs;
  final isLoadingRecentCalls = false.obs;
  final hasMoreRecentCalls = true.obs;

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

        // Sync the device timezone with the backend — the app is
        // international so the backend needs to know each staff's
        // local timezone for day/night coin accounting.
        await _syncTimezone();

        // Check isApproved via isLogin API
        final isValid = await checkIsLogin();
        if (isValid && userProfile.value?.isApproved == true) {
          CustomNavigator.pushCompleteReplacement(RoutePath.bottomNav);
        } else {
          CustomNavigator.pushCompleteReplacement(RoutePath.approval);
        }
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
        'language': signupLanguageController.text.trim(),
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

        // Sync the device timezone with the backend — the app is
        // international so the backend needs to know each staff's
        // local timezone for day/night coin accounting.
        await _syncTimezone();

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
        isOnlineStatus.value = userProfile.value?.status == 'online';

        // Initialize ZegoCloud call invitation so this staff can
        // receive incoming calls (even in killed / background state)
        if (userProfile.value != null && userProfile.value!.isApproved) {
          debugPrint('┌── [AuthController] Initializing Zego ──────────');
          debugPrint('│ staffID: ${userProfile.value!.id}');
          debugPrint('│ staffName: ${userProfile.value!.name}');
          debugPrint('└────────────────────────────────────────────────');

          // Permissions are no longer requested here — they are gated on
          // the online toggle so the staff is prompted only when they
          // actually intend to start receiving calls.
          ZegoCallService.instance.onUserLogin(
            userID: userProfile.value!.id,
            userName: userProfile.value!.name,
          );

          // Register resync callback BEFORE connecting so any reconnect
          // (including the first one) triggers a state refresh — events
          // emitted while we were offline are not buffered by socket.io.
          SocketService.instance.onReconnected = _resyncStateAfterReconnect;

          // Connect to backend socket to receive INCOMING_CALL events
          SocketService.instance.connect(
            staffId: userProfile.value!.id,
            staffName: userProfile.value!.name,
          );
        } else {
          debugPrint('[AuthController] ⚠️ Staff not approved or null, Zego NOT initialized');
        }

        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    // Refuse to log out while still marked online — otherwise the backend
    // keeps routing calls to a staff that is no longer reachable. Ask the
    // user to switch offline first; on confirm, flip status and proceed.
    if (isOnlineStatus.value) {
      final confirmed = await _confirmGoOfflineBeforeLogout();
      if (confirmed != true) return;

      await toggleOnlineStatus(false);
      if (isOnlineStatus.value) {
        Fluttertoast.showToast(msg: 'Failed to go offline, please try again');
        return;
      }
    }

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

  Future<bool?> _confirmGoOfflineBeforeLogout() {
    return Get.dialog<bool>(
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
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_tethering_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'You are online',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please switch to offline before logging out so users stop being routed to you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
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
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Go offline & logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
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

  // ==========================================
  // EDIT PROFILE
  // ==========================================

  // Pre-fill the edit form from the currently cached user profile so the
  // user sees their existing values before changing anything.
  void prefillEditProfileFromCache() {
    final profile = userProfile.value;
    editNameController.text = profile?.name ?? '';
    editAgeController.text = profile?.age?.toString() ?? '';
    editLanguageController.text = profile?.language ?? '';
    editProfileImagePath.value = null;
  }

  Future<void> pickEditProfileImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    editProfileImagePath.value = image.path;
  }

  Future<void> saveProfileChanges() async {
    final name = editNameController.text.trim();
    final ageText = editAgeController.text.trim();
    final language = editLanguageController.text.trim();

    if (name.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your name');
      return;
    }

    int? age;
    if (ageText.isNotEmpty) {
      age = int.tryParse(ageText);
      if (age == null || age <= 0) {
        Fluttertoast.showToast(msg: 'Please enter a valid age');
        return;
      }
    }

    try {
      isUpdatingProfile.value = true;

      // If a new image was picked, upload it first and grab the fileUrl.
      String? uploadedFileUrl;
      final newImagePath = editProfileImagePath.value;
      if (newImagePath != null && newImagePath.isNotEmpty) {
        uploadedFileUrl = await _uploadProfileImage(newImagePath);
        if (uploadedFileUrl == null) return;
      }

      final payload = <String, dynamic>{
        'name': name,
        'age': ?age,
        if (language.isNotEmpty) 'language': language,
        'profileImage': ?uploadedFileUrl,
      };

      final response = await AuthRepository.updateProfile(payload);

      if (response.success) {
        Fluttertoast.showToast(msg: response.message);
        await checkIsLogin();
        editProfileImagePath.value = null;
        CustomNavigator.pop();
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // Uploads an image via the signed-url flow (same as onboarding) and returns
  // the public fileUrl. Returns null and toasts on failure.
  Future<String?> _uploadProfileImage(String imagePath) async {
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
      return null;
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
      return null;
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
      return null;
    }

    return fileUrl;
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

  // Called after the socket reconnects from any drop (network loss, OS-
  // killed TCP socket on background→foreground, etc.). socket.io does not
  // buffer events emitted while we were offline, so we must refetch the
  // REST state that the socket would otherwise keep up to date:
  //   - staff profile / online status
  //   - today's recent calls / earnings
  //   - call history
  void _resyncStateAfterReconnect() {
    debugPrint('[AuthController] Socket reconnected — resyncing REST state');
    // Fire-and-forget; failures are already toasted inside each fetcher.
    checkIsLogin();
    fetchRecentCalls(refresh: true);
    fetchCallHistory(refresh: true);
  }

  Future<void> _clearSessionAndNavigate() async {
    // Disconnect socket and ZegoCloud so we stop receiving calls
    SocketService.instance.onReconnected = null;
    SocketService.instance.disconnect();
    await ZegoCallService.instance.onUserLogout();
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

  // ==========================================
  // ONLINE / OFFLINE TOGGLE
  // ==========================================

  Future<void> toggleOnlineStatus(bool value) async {
    final previousValue = isOnlineStatus.value;

    // When going online, request the runtime permissions Zego needs to
    // deliver incoming calls. Refuse the toggle if any critical one is
    // missing — without them, calls either don't ring or don't arrive.
    if (value) {
      final result = await CallPermissionService.requestAll();
      if (!result.hasAllCritical) {
        Fluttertoast.showToast(
          msg:
              'Cannot go online — please grant: ${result.missingCritical.join(", ")}',
        );
        isOnlineStatus.value = previousValue;
        return;
      }
    }

    try {
      isOnlineStatus.value = value;
      final status = value ? 'online' : 'offline';
      final response = await AuthRepository.updateProfile({'status': status});
      if (response.success) {
        Fluttertoast.showToast(msg: 'Status updated to $status');
      } else {
        isOnlineStatus.value = previousValue;
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      isOnlineStatus.value = previousValue;
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // ==========================================
  // CALL HISTORY
  // ==========================================

  Future<void> fetchCallHistory({bool refresh = false}) async {
    if (refresh) {
      callHistoryPage.value = 1;
      callHistoryList.clear();
      hasMoreCallHistory.value = true;
    }

    if (isLoadingCallHistory.value || !hasMoreCallHistory.value) return;

    try {
      isLoadingCallHistory.value = true;

      final payload = {
        'callerId': '',
        'page': callHistoryPage.value,
        'pageSize': 10,
        'keyword': '',
        'startDate': '',
        'endDate': '',
        'status': '',
      };

      final response = await AuthRepository.getCallHistory(payload);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final resultList = data['result'] as List? ?? [];
        final items = resultList
            .map((e) =>
                CallHistoryItem.fromJson(e as Map<String, dynamic>))
            .toList();

        final paginationMap = data['pagination'] as Map<String, dynamic>?;
        final totalPages = paginationMap?['totalPages'] ?? 1;

        callHistoryList.addAll(items);

        if (callHistoryPage.value >= (totalPages as int)) {
          hasMoreCallHistory.value = false;
        } else {
          callHistoryPage.value++;
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingCallHistory.value = false;
    }
  }

  // ==========================================
  // RECENT CALLS (HOME SCREEN)
  // ==========================================

  Future<void> fetchRecentCalls({bool refresh = false}) async {
    if (refresh) {
      recentCallsPage.value = 1;
      recentCallsList.clear();
      hasMoreRecentCalls.value = true;
    }

    if (isLoadingRecentCalls.value || !hasMoreRecentCalls.value) return;

    try {
      isLoadingRecentCalls.value = true;

      final payload = {
        'page': recentCallsPage.value,
        'pageSize': 10,
      };

      final response = await AuthRepository.getRecentCalls(payload);

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final resultList = data['result'] as List? ?? [];
        final items = resultList
            .map((e) => RecentCallItem.fromJson(e as Map<String, dynamic>))
            .toList();

        final paginationMap = data['pagination'] as Map<String, dynamic>?;
        final totalPages = paginationMap?['totalPages'] is int
            ? paginationMap!['totalPages'] as int
            : 1;

        recentCallsList.addAll(items);

        if (recentCallsPage.value >= totalPages) {
          hasMoreRecentCalls.value = false;
        } else {
          recentCallsPage.value++;
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoadingRecentCalls.value = false;
    }
  }

  // ==========================================
  // TIMEZONE SYNC
  // ==========================================

  // Reads the device's IANA timezone (e.g. "Asia/Kolkata") and pushes it
  // to the backend via the profile update endpoint. Best-effort: failures
  // are swallowed so they never block the auth flow.
  Future<void> _syncTimezone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final identifier = info.identifier;
      if (identifier.isEmpty) return;
      await AuthRepository.updateProfile({'timezone': identifier});
    } catch (_) {
      // Intentionally ignored — timezone sync must not break login/signup.
    }
  }

  String getMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
