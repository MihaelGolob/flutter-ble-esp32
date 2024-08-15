import 'package:ble_demo/ble/models/bt_device_model.dart';

abstract class BtRepository {
  Future<BtDevice> connectToDevice(String deviceName);
  void disconnectFromDevice();
  void onDisconnect(Function callback);
  
  void setVolume(int value);
}

// exceptions

class BtExceptionNotSupported implements Exception {
  final String message = 'Bluetooth is not supported on this device';
}

class BtExceptionError implements Exception {
  final String message;

  BtExceptionError(this.message);
}

class BtExceptionTimeout implements Exception {}
