import 'package:ble_demo/ble/bloc/bt_bloc.dart';
import 'package:ble_demo/global/bt_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Algorhythmo',
          style: TextStyle(color: Theme.of(context).colorScheme.surface),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          BlocBuilder(
            bloc: context.read<BtBloc>(),
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.circle, color: context.read<BtBloc>().isConnected ? Colors.green : Colors.red),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder(
        bloc: context.read<BtBloc>(),
        builder: (context, state) {
          if (state is BtInitial) {
            return Center(
                child: ElevatedButton(
              onPressed: () => context.read<BtBloc>().add(BtFindAndConnectToDevice(deviceName: BtConstants.unitBleName)),
              child: const Text('Connect'),
            ));
          }

          if (state is BtScanning) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BtError) {
            return Center(child: Text(state.message));
          }

          return Center(child: Text('Connected to device: ${(state as BtConnected).device.name}'));
        },
      ),
    );
  }
}
