import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceInfoPage extends StatelessWidget {
  final ScanResult device;
  const DeviceInfoPage({super.key, required this.device});

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: const CircleBorder(),
        child: const Icon(Icons.arrow_upward_rounded),
      ),
    );
  }
}
