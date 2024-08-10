import 'package:ble_demo/providers/ble_device_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              onPressed: () => context.read<BleDeviceProvider>().searchForBleDevices(true),
              child: const Icon(Icons.bluetooth),
            ),
          ],
        ),
        body: Column(
          children: [
            Consumer<BleDeviceProvider>(
              builder: (context, provider, child) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: provider.bleDevices.length,
                    itemBuilder: (context, index) {
                      var device = provider.bleDevices.values.elementAt(index);
                      var name = device.advName;
                      return ListTile(
                        onTap: () => {},
                        title: name.isNotEmpty ? Text(device.advName) : const Text('Unknown device'),
                        subtitle: Text(device.remoteId.toString()),
                        leading: GestureDetector(
                          onTap: () => provider.connectToDevice(device),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: provider.connectedDevice == device ? Colors.green : Colors.blueGrey[200],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: provider.connectedDevice == device ? const Text('Connected') : const Text('Connect'),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ));
  }
}
