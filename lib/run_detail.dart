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
  List<RemoteDevice> devices = [
    RemoteDevice(label: 'Light'),
    RemoteDevice(label: 'Fan'),
    RemoteDevice(label: 'TV'),
    RemoteDevice(label: 'AC'),
    RemoteDevice(label: 'Computer'),
  ];

  Map<String, OffTimer?> offTimers = {};
  String currentDeviceState = '';
  String? lastDeviceTurnedOff;
  List<String> devicesTurnedOff = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remote Control'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display the state of the current device
          Text(
            currentDeviceState,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          // Device buttons in rows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDeviceButton(devices[1]), // Fan
              SizedBox(width: 10),
              _buildDeviceButton(devices[0]), // Light
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDeviceButton(devices[2]), // TV
              SizedBox(width: 10),
              _buildDeviceButton(devices[3]), // AC
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDeviceButton(devices[4]), // Computer
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Undo button logic
                  if (lastDeviceTurnedOff != null &&
                      offTimers.containsKey(lastDeviceTurnedOff)) {
                    setState(() {
                      devices
                          .where((device) =>
                              devicesTurnedOff.contains(device.label) &&
                              device.label != lastDeviceTurnedOff)
                          .forEach((device) {
                        device.turnOff();
                      });
                      devices
                          .firstWhere(
                              (device) => device.label == lastDeviceTurnedOff!)
                          .undo();
                      currentDeviceState = '$lastDeviceTurnedOff is ON';
                      devicesTurnedOff.clear();
                    });
                    lastDeviceTurnedOff = null;
                    _cancelAllOffTimers();
                  }
                },
                child: Text('Undo'),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Countdown display
          if (offTimers.isNotEmpty)
            CountdownDisplay(
              secondsRemaining: offTimers.values.first!.secondsRemaining,
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceButton(RemoteDevice device) {
    return ElevatedButton(
      onPressed: () {
        if (device.isOn) {
          _startOffTimer(device);
          setState(() {
            currentDeviceState = '${device.label} is OFF';
            lastDeviceTurnedOff = device.label;
            devicesTurnedOff.add(device.label);
          });
        } else {
          setState(() {
            device.turnOn();
            currentDeviceState = '${device.label} is ON';
          });
        }
      },
      style: ElevatedButton.styleFrom(
        primary: device.isOn ? Colors.green : Colors.red,
      ),
      child: Text(device.label),
    );
  }

  void _startOffTimer(RemoteDevice device) {
    _cancelOffTimer(device.label);

    offTimers[device.label] = OffTimer(
      seconds: 5,
      onTimerUpdate: (secondsRemaining) {
        setState(() {
          offTimers[device.label]!.secondsRemaining = secondsRemaining;
        });
      },
      onTimerComplete: () {
        if (device.isOn && devicesTurnedOff.contains(device.label)) {
          setState(() {
            device.turnOff();
            currentDeviceState = '${device.label} is OFF';
            offTimers.remove(device.label);
          });
        }
      },
    );
  }

  void _cancelOffTimer(String deviceLabel) {
    offTimers[deviceLabel]?.cancel();
    setState(() {
      offTimers.remove(deviceLabel);
    });
  }

  void _cancelAllOffTimers() {
    for (var device in devices) {
      _cancelOffTimer(device.label);
    }
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

class CountdownDisplay extends StatelessWidget {
  final int secondsRemaining;

  CountdownDisplay({required this.secondsRemaining});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Undo available for $secondsRemaining${secondsRemaining > 1 ? 's' : ''}',
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
