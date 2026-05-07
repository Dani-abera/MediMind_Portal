import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final Connectivity _connectivity;
  final InternetConnection _checker;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  ConnectivityCubit({
    Connectivity? connectivity,
    InternetConnection? checker,
  })  : _connectivity = connectivity ?? Connectivity(),
        _checker = checker ?? InternetConnection(),
        super(ConnectivityStatus.online) {
    _init();
  }

  Future<void> _init() async {
    final initial = await _connectivity.checkConnectivity();
    await _updateFromResults(initial);
    _sub = _connectivity.onConnectivityChanged.listen(_updateFromResults);
  }

  Future<void> _updateFromResults(List<ConnectivityResult> results) async {
    if (results.contains(ConnectivityResult.none)) {
      emit(ConnectivityStatus.offline);
      return;
    }
    final hasInternet = await _checker.hasInternetAccess;
    emit(hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  bool get isOffline => state == ConnectivityStatus.offline;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
