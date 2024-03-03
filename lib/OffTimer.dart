import 'dart:async';

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
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
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
