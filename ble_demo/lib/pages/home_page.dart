import 'package:ble_demo/ble_writer/ble_writer.dart';
import 'package:ble_demo/providers/ble_device_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isScanning = true;

  @override
  void initState() {
    super.initState();

    context.read<BleDeviceProvider>().findAndConnectToDevice(BleWriter.unitBleName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Algorhythmo',
            style: TextStyle(color: Theme.of(context).colorScheme.surface),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Consumer<BleDeviceProvider>(
          builder: (context, provider, child) {
            return isScanning ? const Center(child: CircularProgressIndicator()) : SizedBox();
          },
        ));
  }
}
