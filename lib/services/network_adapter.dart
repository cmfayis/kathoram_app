import 'package:dartz/dartz.dart';
import '../local_storage/shared_pref.dart';
import 'api_base_model.dart';
import 'internet_connectivity.dart';
import 'network.dart';

enum RequestType { get, post, put, delete, Patch }

class BaseClient {
  static final BaseClient shared = BaseClient._privateConstructor();

  BaseClient._privateConstructor();

  final Dio dioInstance = Dio();

  // request timeout (default 10 seconds)

  /// dio getter (used for testing)
  get dio => dioInstance;

  /// perform safe api request
  safeApiCall(
    String url,
    RequestType requestType, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    required Function(ApiBaseModel response) onSuccess,
    Function(Either<ApiException, dynamic>)? onError,
    Function(int value, int progress)? onReceiveProgress,
    Function(int total, int progress)?
    onSendProgress, // while sending (uploading) progress
    Function? onLoading,
    String? accessToken,
    bool isAddBaseUrl = true,
    bool? includeAuth = true,
    dynamic data,
  }) async {
    var option = BaseOptions(
      headers: {'Accept': 'application/json', "client": "OMS"},
      connectTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 90),
      sendTimeout: const Duration(seconds: 90),
    );
    dioInstance.options = option;
    if (isAddBaseUrl) {
      dioInstance.options.baseUrl = ApiConstants.baseUrl;
    } else {
      dioInstance.options.baseUrl = "";
    }
    dioInstance.interceptors.clear();
    dioInstance.interceptors.add(
      CustomLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        dio: dioInstance,
      ),
    );
    try {
      // 1) indicate loading state
      await onLoading?.call();
      // 2) try to perform http request
      late Response response;

      var authToken = "${accessToken ?? MySharedPref.getAuthToken()}";

      if (includeAuth! || accessToken != null) {
        headers = {'Content-Type': 'application/json', "authToken": authToken};
      } else {
        headers = {"Content-Type": "application/x-www-form-urlencoded"};
      }
      var option = Options(headers: headers);
      var temp = await InternetConnectivity.checkConnectivity();

      if (temp != null) {
        if (onError != null) {
          onError(Left(SocketException(temp)));
        }
        return;
      }
      // dioInstance..options=;
      switch (requestType) {
        case RequestType.get:
          response = await dioInstance.get(
            url,
            onReceiveProgress: onReceiveProgress,
            queryParameters: queryParameters,
            options: option,
          );
          break;
        case RequestType.post:
          response = await dioInstance.post(
            url,
            data: data,
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress,
            queryParameters: queryParameters,
            options: option,
          );
          break;
        case RequestType.Patch:
          response = await dioInstance.patch(
            url,
            data: data,
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress,
            queryParameters: queryParameters,
            options: option,
          );
          break;
        case RequestType.put:
          response = await dioInstance.put(
            url,
            data: data,
            onReceiveProgress: onReceiveProgress,
            onSendProgress: onSendProgress,
            queryParameters: queryParameters,
            options: option,
          );
          break;
        case RequestType.delete:
          response = await dioInstance.delete(
            url,
            data: data,
            queryParameters: queryParameters,
            options: option,
          );
          break;
      }
      // 3) return response (api done successfully)

      await onSuccess(ApiBaseModel.fromJson(response.data));
    } on DioException catch (error) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          onError != null
              ? onError(Left(TimeOutException(url)))
              : _handleError(TimeOutException());
          break;
        case DioExceptionType.connectionError:
          onError != null
              ? onError(Left(UndefinedException()))
              : _handleError(UndefinedException());
        case DioExceptionType.badResponse:
          if (onError != null) {
            onError(
              Right(
                FetchDataException(
                  error.response != null
                      ? error.response!.data
                      : "Unknown Error",
                ),
              ),
            );
          } else {
            _handleError(TimeOutException());
          }
          // response = error.response!; // If response is available.
          break;
        case DioExceptionType.cancel:
          onError != null
              ? onError(
                  Left(
                    FetchDataException(
                      'Request Cancelled\n\n${error.message}',
                      url,
                    ),
                  ),
                )
              : _handleError(
                  FetchDataException('Request Cancelled\n\n${error.message}'),
                );
        default:
          onError != null
              ? onError(Left(FetchDataException(error.message, url)))
              : _handleError(FetchDataException(error.message));
      }

      // dio error (api reach the server but not performed successfully
      //_handleDioError(error: error, url: url, onError: onError);
    } on SocketException {
      // No internet connection
      return onError != null
          ? onError(Left(SocketException(url)))
          : _handleError(SocketException());
    } catch (error) {
      // print the line of code that throw unexpected exception
      ///Logger().e(stackTrace);
      // unexpected error for example (parsing json error)
      return onError != null
          ? onError(Left(UndefinedException(error, url)))
          : _handleError(UndefinedException(error));
    }
  }

  /// handle error automaticly (if user didnt pass onError) method
  /// it will try to show the message from api if there is no message
  /// from api it will show the reason (the dio message)
  static handleApiException(ApiException apiException) {
    String msg = apiException.message;
    // CustomSnackBar.showCustomErrorToast(message: msg);
  }

  static handleApiError(Failure failure) {
    String msg = failure.message.toString();
    // CustomSnackBar.showCustomErrorToast(message: msg);
  }

  /// handle errors without response (500, out of time, no internet,..etc)
  static _handleError(ApiException msg) {
    // CustomSnackBar.showCustomErrorToast(message: msg.message);
  }
}

getErrorMessageApi(ApiException exception) {
  if (exception.url != null) {
    try {
      return "${(exception.url as Response).data["msg"]}";
    } catch (e) {
      return exception.message;
    }
  } else {
    return exception.message;
  }
}
