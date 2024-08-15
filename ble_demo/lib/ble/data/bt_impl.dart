import 'dart:async';
import 'dart:io';

import 'package:ble_demo/ble/data/bt_repository.dart';
import 'package:ble_demo/ble/models/bt_device_model.dart';
import 'package:ble_demo/global/bt_constants.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BtImpl implements BtRepository {
  BluetoothDevice? connectedDevice;

  BtImpl() {
    _initBt();
  }

  @override
  Future<BtDevice> connectToDevice(String deviceName) async {
    final connectionCompleter = Completer<void>();

    var onScanResults = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isEmpty || connectedDevice != null) {
        return;
      }

      // if found, connect to the first device found
      print('Found device: ${results.first.device.remoteId} - ${results.first.advertisementData.advName}');
      _connectToDevice(results.first.device).then((_) => connectionCompleter.complete());
    }, onError: (e) => throw BtExceptionError(e));
    FlutterBluePlus.cancelWhenScanComplete(onScanResults); // cleanup subscription

    // wait for bt to be enabled and permission granted
    await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;
    print('Starting to scan for device: $deviceName');
    await FlutterBluePlus.startScan(
      withNames: [deviceName],
      timeout: const Duration(seconds: 10),
    );

    // wait for connection to be established or timeout
    await Future.any([
      connectionCompleter.future,
      FlutterBluePlus.isScanning.where((val) => val == false).first,
    ]);

    if (connectedDevice == null) {
      throw BtExceptionTimeout();
    }

    return BtDevice(id: connectedDevice!.remoteId.toString(), name: connectedDevice!.advName);
  }

  @override
  void disconnectFromDevice() {
    if (connectedDevice != null) {
      connectedDevice!.disconnect();
    }
  }

  @override
  void setVolume(int value) async {
    if (connectedDevice == null) {
      print('Cannot set volume, no device connected');
    }

    // todo: rework
    final services = await connectedDevice!.discoverServices();
    final algService = services.firstWhere((service) => service.uuid.toString() == BtConstants.serviceUuid);
    final volumeChar = algService.characteristics.firstWhere((char) => char.uuid.toString() == BtConstants.volumeChar);

    await volumeChar.write([value]);
  }

  // P R I V A T E  M E T H O D S

  void _initBt() async {
    if (!await _isBleSupported()) {
      print('Bluetooth is not supported on this device');
      throw BtExceptionNotSupported();
    }

    if (Platform.isAndroid) {
      print('Automatically turning on Bluetooth');
      await FlutterBluePlus.turnOn();
    }
  }

  Future<bool> _isBleSupported() async {
    return await FlutterBluePlus.isSupported;
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    print('Trying to connect: ${device.remoteId} - ${device.advName}');

    if (connectedDevice == device) {
      print('Already connected to device ${device.advName}');
      return;
    }

    disconnectFromDevice();

    var onConnection = device.connectionState.listen((BluetoothConnectionState state) => _onConnectionChanged(state, device));

    device.cancelWhenDisconnected(onConnection, delayed: true, next: true);

    await device.connect();
  }

  void _onConnectionChanged(BluetoothConnectionState state, BluetoothDevice device) {
    if (state == BluetoothConnectionState.connected) {
      print('Connected to: ${device.advName}');
      connectedDevice = device;
    } else if (state == BluetoothConnectionState.disconnected) {
      print('Disconnected');
      connectedDevice = null;
    }
  }
}
