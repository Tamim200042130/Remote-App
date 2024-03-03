import 'package:flutter/material.dart';

import 'CountDownDisplay.dart';
import 'OffTimer.dart';
import 'RemoteDevice.dart';

class RemoteScreen extends StatefulWidget {
  const RemoteScreen({Key? key}) : super(key: key);

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
    RemoteDevice(label: 'Heater'),
  ];

  Map<String, OffTimer?> offTimers = {};
  String currentDeviceState = '';
  String? lastDeviceTurnedOff;
  List<String> devicesTurnedOff = [];
  int secondsRemaining = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[800],
        title: Center(child: const Text('Remote Control')),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30),




          // Display the state of the current device
          Container(
            width: 390,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.purple,
              border: Border.all(
                color: Colors.white,
                width: 5.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                currentDeviceState,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),



          // Device buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildDeviceButton(devices[1])),
              const SizedBox(width: 10),
              Expanded(child: _buildDeviceButton(devices[0])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildDeviceButton(devices[2])),
              const SizedBox(width: 10),
              Expanded(child: _buildDeviceButton(devices[3])),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildDeviceButton(devices[4])),
              const SizedBox(width: 10),
              Expanded(child: _buildDeviceButton(devices[5])),
            ],
          ),
          const SizedBox(height: 20),



          // Countdown display
          if (secondsRemaining > 0)
            CountdownDisplay(
              deviceLabel: lastDeviceTurnedOff ?? '',
              secondsRemaining: secondsRemaining,
            ),
          const Spacer(),



          // Undo button
          ElevatedButton(
            onPressed: () {
              if (lastDeviceTurnedOff != null &&
                  offTimers.containsKey(lastDeviceTurnedOff)) {
                setState(() {
                  devices
                      .where(
                    (device) =>
                        devicesTurnedOff.contains(device.label) &&
                        device.label != lastDeviceTurnedOff,
                  )
                      .forEach((device) {
                    device.turnOff();
                  });
                  devices
                      .firstWhere(
                        (device) => device.label == lastDeviceTurnedOff!,
                      )
                      .undo();
                  currentDeviceState = '$lastDeviceTurnedOff is ON';
                  devicesTurnedOff.clear();
                  secondsRemaining = 0;
                });
                lastDeviceTurnedOff = null;
                _cancelAllOffTimers();
              }
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.purple[800],
              padding: const EdgeInsets.all(8.0),
              fixedSize: Size(800, 80),
            ),
            child: const Text(
              'Undo',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }



  // Build device button
  Widget _buildDeviceButton(RemoteDevice device) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
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
          shape: CircleBorder(),
          side: BorderSide(color: Colors.purple[800]!, width: 5.0),
          fixedSize: const Size(100, 100),
        ),
        child: Text(
          device.label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Text color
          ),
        ),
      ),
    );
  }


  //Start the off timer
  void _startOffTimer(RemoteDevice device) {
    _cancelOffTimer(device.label);

    offTimers[device.label] = OffTimer(
      seconds: 5,
      onTimerUpdate: (secondsRemaining) {
        setState(() {
          this.secondsRemaining = secondsRemaining;
        });
      },
      onTimerComplete: () {
        if (device.isOn && devicesTurnedOff.contains(device.label)) {
          setState(() {
            device.turnOff();
            currentDeviceState = '${device.label} is OFF';
            offTimers.remove(device.label);
            secondsRemaining = 0;
          });
        }
      },
    );
  }



  //Cancel the off timer
  void _cancelOffTimer(String deviceLabel) {
    offTimers[deviceLabel]?.cancel();
    setState(() {
      offTimers.remove(deviceLabel);
    });
  }


  //Cancel all off timers
  void _cancelAllOffTimers() {
    for (var device in devices) {
      _cancelOffTimer(device.label);
    }
  }
}
