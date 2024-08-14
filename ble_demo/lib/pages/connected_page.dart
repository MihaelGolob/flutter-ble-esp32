import 'package:ble_demo/ble/bloc/bt_bloc.dart';
import 'package:ble_demo/widgets/alg_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectedPage extends StatelessWidget {
  const ConnectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('V O L U M E', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          AlgSlider(
            onChanged: (value) {
              context.read<BtBloc>().setVolume(value);
            },
          ),
        ],
      ),
    );
  }
}
