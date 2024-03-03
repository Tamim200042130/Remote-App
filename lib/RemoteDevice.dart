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
