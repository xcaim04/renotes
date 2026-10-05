import 'package:flutter/material.dart';

import 'data/app_store.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';
import 'widgets/app_scope.dart';

/// Punto de entrada de ReNotes.
///
/// La app no tiene servidor ni base de datos: todo vive en memoria durante la
/// sesión, así que [AppStore] se crea aquí y se expone con [AppScope].
void main() {
  runApp(const ReNotesApp());
}

class ReNotesApp extends StatefulWidget {
  const ReNotesApp({super.key});

  @override
  State<ReNotesApp> createState() => _ReNotesAppState();
}

class _ReNotesAppState extends State<ReNotesApp> {
  // El store se crea una vez y sobrevive a los reconstrucciones del widget raíz,
  // de modo que las pestañas conserven su posición y sus filtros.
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