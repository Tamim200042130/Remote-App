import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(RemoteApp());

class RemoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RemoteScreen(),
    );
  }
}

class RemoteScreen extends StatefulWidget {
  @override
  _RemoteScreenState createState() => _RemoteScreenState();
}

class _RemoteScreenState extends State<RemoteScreen> {
  RemoteDevice _light = RemoteDevice(label: 'Light');
  OffTimer? _offTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remote Control'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            _light.isOn ? 'Light is ON' : 'Light is OFF',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),

          // Grid of device buttons
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            children: [
              RemoteButton(
                remoteDevice: _light,
                onPressed: () {

                  if (_light.isOn) {
                    _startOffTimer();
                  } else {

                    setState(() {
                      _light.turnOn();
                    });
                  }
                },
              ),

            ],
          ),

          SizedBox(height: 20),

          // Countdown display
          if (_offTimer != null && _light.isOn)
            CountdownDisplay(
              secondsRemaining: _offTimer!.secondsRemaining,
            ),

          // Undo button
          ElevatedButton(
            onPressed: () {

              _cancelOffTimer();

              if (_light.isOn) {
                setState(() {
                  _light.undo();
                });
              }
            },
            child: Text('Undo'),
          ),
        ],
      ),
    );
  }

  void _startOffTimer() {

    _cancelOffTimer();


    _offTimer = OffTimer(
      seconds: 5,
      onTimerUpdate: (secondsRemaining) {
        setState(() {

          _offTimer!.secondsRemaining = secondsRemaining;
        });
      },
      onTimerComplete: () {

        if (_light.isOn) {
          setState(() {
            _light.turnOff();
          });
        }
      },
    );
  }

  void _cancelOffTimer() {

    _offTimer?.cancel();
    setState(() {
      _offTimer = null;
    });
  }

  @override
  void dispose() {

    _cancelOffTimer();
    super.dispose();
  }
}

class RemoteDevice {
  String label;
  bool isOn;

  RemoteDevice({required this.label, this.isOn = false});

  void turnOn() {

    isOn = true;
  }

  void turnOff() {

    isOn = false;
  }

  void undo() {

    isOn = true;
  }
}

class RemoteButton extends StatelessWidget {
  final RemoteDevice remoteDevice;
  final VoidCallback onPressed;

  RemoteButton({required this.remoteDevice, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: remoteDevice.isOn ? Colors.green : Colors.red,
      ),
      child: Text(remoteDevice.label),
    );
  }
}

class CountdownDisplay extends StatelessWidget {
  final int secondsRemaining;

  CountdownDisplay({required this.secondsRemaining});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Undo available for ${secondsRemaining}s',
      style: TextStyle(fontSize: 16, color: Colors.blue),
    );
  }
}

class OffTimer {
  late Timer _timer;
  final int seconds;
  final Function(int) onTimerUpdate;
  final Function onTimerComplete;
  int secondsRemaining;

  OffTimer({
    required this.seconds,
    required this.onTimerUpdate,
    required this.onTimerComplete,
  }) : secondsRemaining = seconds {
    _timer = Timer.periodic(Duration(seconds: 1), _updateTimer);
  }

  void _updateTimer(Timer timer) {
    secondsRemaining = seconds - timer.tick;
    onTimerUpdate(secondsRemaining);

    if (secondsRemaining <= 0) {
      _timer.cancel();
      onTimerComplete();
    }
  }

  void cancel() {
    _timer.cancel();
  }
}
