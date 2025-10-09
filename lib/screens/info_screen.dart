import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("🏠 InfoScreen", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
