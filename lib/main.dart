import 'package:flutter/material.dart';
import 'RemoteScreen.dart';

void main() => runApp(const RemoteApp());

class RemoteApp extends StatelessWidget {
  const RemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RemoteScreen(),
    );
  }
}
