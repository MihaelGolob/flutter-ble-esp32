import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:ble_demo/ble/data/bt_repository.dart';
import 'package:ble_demo/ble/models/bt_device_model.dart';
import 'package:ble_demo/global/bt_constants.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BtImpl implements BtRepository {
  BluetoothDevice? connectedDevice;
  Function? _onDisconnect;
  final HashMap<BtCharacteristic, BluetoothCharacteristic> _characteristics = HashMap();
  final HashMap<BtService, BluetoothService> _services = HashMap();

  // TODO: move this data somewhere else
  int volume = 0;

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

    final volumeChar = await _findCharacteristic(BtConstants.volumeChar);

    volume = value;
    await volumeChar.write([value]);
  }

  @override
  int getVolume() {
    return volume;
  }

  @override
  void onDisconnect(Function callback) {
    _onDisconnect = callback;
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
    await _readInitialValues();
  }

  void _onConnectionChanged(BluetoothConnectionState state, BluetoothDevice device) {
    if (state == BluetoothConnectionState.connected) {
      print('Connected to: ${device.advName}');
      connectedDevice = device;
    } else if (state == BluetoothConnectionState.disconnected) {
      print('Disconnected');
      connectedDevice = null;
      _onDisconnect?.call();
    }
  }

  Future<void> _readInitialValues() async {
    if (connectedDevice == null) {
      print('Cannot read values, no device connected');
    }

    final volumeChar = await _findCharacteristic(BtConstants.volumeChar);
    volume = await volumeChar.read().then((value) => value.first);
  }

  Future<BluetoothCharacteristic> _findCharacteristic(BtCharacteristic characteristic) async {
    if (_characteristics.containsKey(characteristic)) {
      return _characteristics[characteristic]!;
    }

    final parentService = await _findService(characteristic.parentService);
    final char = parentService.characteristics.firstWhere((char) => char.uuid.toString() == characteristic.uuid);

    _characteristics[characteristic] = char;
    return char;
  }

  Future<BluetoothService> _findService(BtService service) async {
    if (_services.containsKey(service)) {
      return _services[service]!;
    }

    final services = await connectedDevice!.discoverServices();
    return services.firstWhere((s) => s.uuid.toString() == service.uuid);
  }
}
