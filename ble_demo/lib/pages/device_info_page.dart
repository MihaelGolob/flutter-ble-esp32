import 'package:ble_demo/providers/ble_device_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  void onSetVolume(BuildContext context, double value) {
    context.read<BleDeviceProvider>().setVolume(value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BleDeviceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              provider.connectedDevice?.advName ?? 'Unknown device',
              style: TextStyle(color: Theme.of(context).colorScheme.surface),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  context.read<BleDeviceProvider>().writeTestCharacteristic();
                },
                shape: const CircleBorder(),
                child: const Text('Write'),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  context.read<BleDeviceProvider>().discoverServices();
                },
                shape: const CircleBorder(),
                child: const Text('Services'),
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text('Adjust volume', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Slider(
                    value: provider.getVolume.toDouble(),
                    min: 0,
                    max: 100,
                    label: provider.getVolume.round().toString(),
                    onChanged: (value) => onSetVolume(context, value),
                  ),
                ),
                Text(provider.getVolume.round().toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}
