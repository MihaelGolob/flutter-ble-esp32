import 'package:ble_demo/providers/ble_device_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeviceInfoPage extends StatelessWidget {
  const DeviceInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About device ...',
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
              context.read<BleDeviceProvider>().writeTestCharacteristic();
            },
            shape: const CircleBorder(),
            child: const Text('Services'),
          ),
        ],
      ),
      body: Consumer<BleDeviceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              ListTile(
                title: Text(provider.connectedDevice!.advName),
                subtitle: Text(provider.connectedDevice!.remoteId.toString()),
              ),
              const SizedBox(height: 10),
              provider.services == null
                  ? const SizedBox()
                  : SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: provider.services!.length,
                        itemBuilder: (context, index) {
                          var service = provider.services![index];
                          return ListTile(
                            title: Text(service.uuid.toString()),
                            subtitle: Text(service.characteristics.length.toString()),
                          );
                        },
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
