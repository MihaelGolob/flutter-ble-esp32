import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleDeviceProvider extends ChangeNotifier {
  Map<String, BluetoothDevice> bleDevices = {};
  BluetoothDevice? connectedDevice;
  List<BluetoothService>? services;

  void _addDeviceToCache(BluetoothDevice device) {
    if (!bleDevices.containsKey(device.remoteId.toString())) {
      bleDevices[device.remoteId.toString()] = device;
      print('Found device: ${device.remoteId} - ${device.advName}');
    }

    notifyListeners();
  }

  void _clearDevices() {
    bleDevices.clear();
    notifyListeners();
  }

  void searchForBleDevices(bool clear) async {
    if (clear) {
      _clearDevices();
    }

    var bleSupported = await FlutterBluePlus.isSupported;
    print('BLE supported: $bleSupported');

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    if (connectedDevice != null) {
      _addDeviceToCache(connectedDevice!);
    }

    // Start scanning for BLE devices
    var onScanResults = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isEmpty) return;

      for (var result in results) {
        _addDeviceToCache(result.device);
      }
    }, onError: (e) => print('Error when scanning for devices: $e'));

    FlutterBluePlus.cancelWhenScanComplete(onScanResults);
    await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  void connectToDevice(BluetoothDevice device) async {
    print('Trying to connect to device: ${device.remoteId} - ${device.advName}');

    if (connectedDevice == device) {
      await connectedDevice!.disconnect();
      return;
    } else if (connectedDevice != null) {
      await connectedDevice!.disconnect();
    }

    var onConnection = device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.connected) {
        print('Connected to device: ${device.remoteId} - ${device.advName}');
        connectedDevice = device;
        notifyListeners();
      } else if (state == BluetoothConnectionState.disconnected) {
        print('Disconnected from device: ${device.remoteId} - ${device.advName}');
        connectedDevice = null;
        notifyListeners();
      }
    });

    device.cancelWhenDisconnected(onConnection, delayed: true, next: true);

    await device.connect();
  }

  void discoverServices() async {
    if (connectedDevice == null) return;
    services = await connectedDevice!.discoverServices();
  }

  void writeTestCharacteristic() async {
    if (services == null || services!.isEmpty) {
      discoverServices();
      return;
    }

    final service = services!.firstWhere((c) => c.uuid.toString() == '00ff');
    final characteristics = service.characteristics;

    final writeChr = characteristics.first;
    await writeChr.write([0x88, 0x99]);
  }
}
