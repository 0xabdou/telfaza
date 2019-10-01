import 'dart:async';

import 'package:telfaza/bloc/bloc_base.dart';

class ConnectivityBloc extends BaseBloc {
  bool _canEmit = true;

  final StreamController<bool> _connectivityControllerIn =
      StreamController<bool>();
  Sink<bool> get inConnectivity => _connectivityControllerIn.sink;

  final StreamController<bool> _connectivityControllerOut =
      StreamController<bool>.broadcast();
  Stream<bool> get outConnectivity => _connectivityControllerOut.stream;

  ConnectivityBloc() {
    _connectivityControllerIn.stream.listen((connected) {
      if (_canEmit) {
        _connectivityControllerOut.add(connected);
        _canEmit = false;
        Timer(Duration(seconds: 10), () {
          _canEmit = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivityControllerIn.close();
    _connectivityControllerOut.close();
  }
}
