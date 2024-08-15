import 'package:ble_demo/ble/bloc/bt_bloc.dart';
import 'package:ble_demo/global/bt_constants.dart';
import 'package:ble_demo/pages/connected_page.dart';
import 'package:ble_demo/widgets/button.dart';
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
        title: const Text(
          'Algorhythmo',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey,
        actions: [
          BlocBuilder(
            bloc: context.read<BtBloc>(),
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: IconButton(
                  icon: const Icon(Icons.circle),
                  onPressed: () => context.read<BtBloc>().add(BtDisconnect()),
                  color: state is BtConnected ? Colors.green : Colors.red,
                ),
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
              child: Button(
                onTap: () => context.read<BtBloc>().add(BtFindAndConnectToDevice(deviceName: BtConstants.unitBleName)),
                text: 'Connect',
              ),
            );
          }

          if (state is BtScanning) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BtError) {
            return Center(child: Text(state.message));
          }

          return const ConnectedPage();
        },
      ),
    );
  }
}
