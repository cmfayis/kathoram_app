import '../../../../services/api_base_model.dart';
import '../../../../services/api_constants.dart';
import '../../../../services/network_adapter.dart';

class AuthRepository {
  static Future<ApiBaseModel> login(Map<String, dynamic> payload) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.login,
      RequestType.post,
      data: payload,
      includeAuth: false,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold((l) => throw l.message, (r) => throw r);
      },
    );
    return response;
  }

  static Future<ApiBaseModel> signup(Map<String, dynamic> payload) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.signup,
      RequestType.post,
      data: payload,
      includeAuth: false,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold((l) => throw l.message, (r) => throw r);
      },
    );
    return response;
  }

  static Future<ApiBaseModel> isLogin() async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.isLogin,
      RequestType.get,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold((l) => throw l.message, (r) => throw r);
      },
    );
    return response;
  }

  static Future<ApiBaseModel> logout() async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.logout,
      RequestType.get,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold((l) => throw l.message, (r) => throw r);
      },
    );
    return response;
  }

  static Future<ApiBaseModel> deleteAccount() async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.deleteAccount,
      RequestType.get,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold((l) => throw l.message, (r) => throw r);
      },
    );
    return response;
  }

  static Future<ApiBaseModel> getUploadUrl({
    required String fileName,
    required String fileType,
  }) async {
    late ApiBaseModel response;

    await BaseClient.shared.safeApiCall(
      ApiConstants.fileupload,
      RequestType.put,
      data: {'fileName': fileName, 'fileType': fileType},
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold((l) => throw l.message, (r) => throw r);
      },
    );
    return response;
  }

  static Future<ApiBaseModel> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    late ApiBaseModel response;
    await BaseClient.shared.safeApiCall(
      ApiConstants.updateProfile,
      RequestType.Patch,
      data: payload,
      onSuccess: (s) {
        response = s;
      },
      onError: (s) {
        s.fold((l) => throw l.message, (r) => throw r);
      },
    );
    return response;
  }
}
