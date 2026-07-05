import 'dart:async';
import 'dart:io';

import '../errors/app_exceptions.dart';

Future<T> safeRemoteCall<T>(
  Future<T> Function() action, {
  Duration timeout = const Duration(seconds: 12),
}) async {
  try {
    return await action().timeout(timeout);
  } on AppException {
    rethrow;
  } on SocketException {
    throw const NetworkUnavailableException();
  } on TimeoutException {
    throw const RemoteRequestTimeoutException();
  } on HttpException {
    throw const RemoteServiceUnavailableException();
  } on FormatException {
    throw const InvalidRemoteResponseException();
  } catch (_) {
    throw const RemoteServiceUnavailableException();
  }
}
