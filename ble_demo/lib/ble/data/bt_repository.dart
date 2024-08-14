abstract class BtRepository {
  void initBt();
  void connectToDevice(String deviceName);
  void disconnectFromDevice();
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
