class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkUnavailableException extends AppException {
  const NetworkUnavailableException()
      : super('No internet connection or the network is unavailable.');
}

class RemoteRequestTimeoutException extends AppException {
  const RemoteRequestTimeoutException()
      : super('The request took too long to complete.');
}

class RemoteServiceUnavailableException extends AppException {
  const RemoteServiceUnavailableException()
      : super('The remote service is unavailable right now.');
}

class InvalidRemoteResponseException extends AppException {
  const InvalidRemoteResponseException()
      : super('The remote service returned an invalid response.');
}
