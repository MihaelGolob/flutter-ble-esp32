import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, ScanResult> bleDevices = {};
  ScanResult? connectedDevice;

  void _findBLEDevices() async {
    var bleSupported = await FlutterBluePlus.isSupported;
    print('BLE supported: $bleSupported');

    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // Start scanning for BLE devices
    var onScanResults = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isEmpty) return;

      for (var result in results) {
        if (!bleDevices.containsKey(result.device.remoteId.toString())) {
          bleDevices[result.device.remoteId.toString()] = result;
          setState(() {});
          print('Found device: ${result.device.remoteId} - ${result.advertisementData.advName}');
        }
      }
    }, onError: (e) => print('Error when scanning for devices: $e'));

    FlutterBluePlus.cancelWhenScanComplete(onScanResults);
    await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  void _connectToDevice(ScanResult device) async {
    print('Trying to connect to device: ${device.device.remoteId} - ${device.advertisementData.advName}');

    if (connectedDevice == device) {
      await connectedDevice!.device.disconnect();
      return;
    } else if (connectedDevice != null) {
      await connectedDevice!.device.disconnect();
    }

    var onConnection = device.device.connectionState.listen((BluetoothConnectionState state) async {
      if (state == BluetoothConnectionState.connected) {
        print('Connected to device: ${device.device.remoteId} - ${device.advertisementData.advName}');
        connectedDevice = device;
        setState(() {});
      } else if (state == BluetoothConnectionState.disconnected) {
        print('Disconnected from device: ${device.device.remoteId} - ${device.advertisementData.advName}');
        connectedDevice = null;
        setState(() {});
      }
    });

    device.device.cancelWhenDisconnected(onConnection, delayed: true, next: true);

    await device.device.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'BLE demo',
            style: TextStyle(color: Theme.of(context).colorScheme.surface),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {},
              shape: const CircleBorder(),
              child: const Icon(Icons.arrow_upward_rounded),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              shape: const CircleBorder(),
              onPressed: () {
                bleDevices.clear();
                setState(() {});
                _findBLEDevices();
              },
              child: const Icon(Icons.bluetooth),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: bleDevices.length,
                itemBuilder: (context, index) {
                  var device = bleDevices.values.elementAt(index);
                  var name = device.advertisementData.advName;
                  return ListTile(
                    title: name.isNotEmpty ? Text(device.advertisementData.advName) : const Text('Unknown device'),
                    subtitle: Text(device.device.remoteId.toString()),
                    leading: GestureDetector(
                      onTap: () => _connectToDevice(device),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: connectedDevice == device ? Colors.green : Colors.blueGrey[200],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: connectedDevice == device ? const Text('Connected') : const Text('Connect'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
