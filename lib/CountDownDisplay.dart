import 'package:flutter/material.dart';

class CountdownDisplay extends StatelessWidget {
  final String deviceLabel;
  final int secondsRemaining;

  const CountdownDisplay(
      {super.key, required this.deviceLabel, required this.secondsRemaining});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Undo available for $deviceLabel${secondsRemaining > 1
          ? ' for $secondsRemaining seconds'
          : ''}',
      style: TextStyle(
          fontSize: 20, color: Colors.purple[800], fontWeight: FontWeight.bold),
    );
  }
}
