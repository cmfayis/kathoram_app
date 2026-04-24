class ApiException implements Exception {
  final dynamic url;
  final String message;
  final dynamic statusCode;

  ApiException({this.url, required this.message, this.statusCode = 200});
}

class FetchDataException extends ApiException {
  FetchDataException([message, url, statusCode])
      : super(
            message: message ?? "Fetch Data Error",
            url: url,
            statusCode: statusCode);
}

class SocketException extends ApiException {
  SocketException([message, url, statusCode])
      : super(
            message: message ?? "No Internet Connection",
            url: url,
            statusCode: statusCode);
}

class TimeOutException extends ApiException {
  TimeOutException([message, url, statusCode])
      : super(
            message: "Server not responding", url: url, statusCode: statusCode);
}

class UndefinedException extends ApiException {
  UndefinedException([message, url, statusCode])
      : super(
            message: message == null ? "Something went wrong" : "$message",
            url: url,
            statusCode: statusCode);
}
