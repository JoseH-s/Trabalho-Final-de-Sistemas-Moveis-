import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:provider/provider.dart";
import "package:pomodoro/pomodoro_app.dart";
import "package:pomodoro/pomodoro_provider.dart";
import "package:sqflite_common_ffi_web/sqflite_ffi_web.dart";
import "package:sqflite_common/sqflite.dart";

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => PomodoroProvider()..carregarRegistros(),
      child: const PomodoroApp(),
    ),
  );
}
