import 'package:flutter/material.dart';

import 'data/app_store.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';
import 'widgets/app_scope.dart';

void main() {
  runApp(const ReNotesApp());
}

class ReNotesApp extends StatefulWidget {
  const ReNotesApp({super.key});

  @override
  State<ReNotesApp> createState() => _ReNotesAppState();
}

class _ReNotesAppState extends State<ReNotesApp> {
  
  late final AppStore _store = AppStore();

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: _store,
      child: AnimatedBuilder(
        animation: _store,
        builder: (BuildContext context, Widget? hijo) {
          return MaterialApp(
            title: 'ReNotes',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _store.tema,
            home: hijo,
          );
        },
        child: const HomeShell(),
      ),
    );
  }
}