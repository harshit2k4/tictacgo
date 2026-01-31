import 'package:flutter/material.dart';

class TicTacGoApp extends StatelessWidget {
  const TicTacGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Go',
      // Material 3 implementation
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue, // Primary color
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const Scaffold(body: Center(child: Text('Tic Tac Go Ready'))),
    );
  }
}
