import 'package:flutter/material.dart';

class AlgSlider extends StatefulWidget {
  final int min;
  final int max;
  final int startValue;
  final Function(int) onChanged;
  const AlgSlider({super.key, this.min = 0, this.max = 100, required this.onChanged, this.startValue = 50});

  @override
  State<AlgSlider> createState() => _AlgSliderState();
}

class _AlgSliderState extends State<AlgSlider> {
  int _value = 0;

  @override
  void initState() {
    super.initState();
    _value = widget.startValue;
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: const SliderThemeData(
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
        trackHeight: 15,
        activeTrackColor: Colors.blueGrey,
      ),
      child: Slider(
        value: _value.toDouble(),
        onChanged: (value) => setState(() {
          _value = value.toInt();
          widget.onChanged(_value);
        }),
        min: widget.min.toDouble(),
        max: widget.max.toDouble(),
      ),
    );
  }
}
