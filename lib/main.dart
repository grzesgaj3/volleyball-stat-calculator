import 'package:flutter/material.dart';
import 'screens/match_title_screen.dart';

void main() {
  runApp(const VolleyballStatCalculatorApp());
}

class VolleyballStatCalculatorApp extends StatelessWidget {
  const VolleyballStatCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volleyball Stat Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MatchTitleScreen(),
    );
  }
}
