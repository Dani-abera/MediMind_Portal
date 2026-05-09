import 'dart:io';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<InternetStatus> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _checker;

  NetworkInfoImpl(this._checker);

  @override
  Future<bool> get isConnected async {
    // On desktop, the connectivity package frequently false-negatives.
    // Return true and let Dio surface real network errors instead.
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return true;
    }
    return _checker.hasInternetAccess;
  }

  @override
  Stream<InternetStatus> get onStatusChange => _checker.onStatusChange;
}
