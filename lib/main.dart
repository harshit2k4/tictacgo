import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tictacgo/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope stores the state of all Riverpod providers
    const ProviderScope(child: TicTacGoApp()),
  );
}
