import 'slider_overlay.dart';

import 'package:flutter/material.dart';

class SpeedControl extends StatefulWidget {
  final double speed;
  final ValueChanged<double> onChanged;
  const SpeedControl({super.key, required this.speed, required this.onChanged});
  @override
  State<SpeedControl> createState() => _SpeedControlState();
}

class _SpeedControlState extends State<SpeedControl> {
  late final text = TextEditingController(
    text: '${(widget.speed * 100).round()}',
  );
  final focus = FocusNode();
  String? error;
  @override
  void didUpdateWidget(covariant SpeedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      text.text = '${(widget.speed * 100).round()}';
      error = null;
    }
  }

  void submit(String value) {
    final number = int.tryParse(value.trim());
    if (number == null || number < 25 || number > 150) {
      setState(() => error = 'Enter 25–150');
      return;
    }
    setState(() => error = null);
    widget.onChanged(number / 100);
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Text('Speed'),
      Expanded(
        child: sliderWithLocalOverlay(
          Slider(
            value: widget.speed,
            min: .25,
            max: 1.5,
            divisions: 125,
            label: '${(widget.speed * 100).round()}%',
            semanticFormatterCallback: (v) =>
                '${(v * 100).round()} percent speed',
            onChanged: (v) => widget.onChanged((v * 100).round() / 100),
          ),
        ),
      ),
      SizedBox(
        width: 85,
        child: TextField(
          controller: text,
          focusNode: focus,
          keyboardType: TextInputType.number,
          onSubmitted: submit,
          onTapOutside: (_) {
            if (focus.hasFocus) {
              submit(text.text);
              focus.unfocus();
            }
          },
          decoration: InputDecoration(
            labelText: 'Percent',
            suffixText: '%',
            errorText: error,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      IconButton(
        tooltip: 'Reset speed to 100%',
        onPressed: () {
          setState(() {
            text.text = '100';
            error = null;
          });
          widget.onChanged(1);
        },
        icon: const Icon(Icons.restore),
      ),
    ],
  );
  @override
  void dispose() {
    text.dispose();
    focus.dispose();
    super.dispose();
  }
}
