import 'package:ble_demo/widgets/alg_slider.dart';
import 'package:flutter/material.dart';

class ConnectedPage extends StatelessWidget {
  const ConnectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AlgSlider(
          onChanged: (value) {},
        ),
      ],
    );
  }
}
