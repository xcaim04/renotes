import 'package:flutter/material.dart';

import '../data/app_store.dart';

/// Expone el [AppStore] al árbol de widgets y reconstruye a los dependientes
/// cuando el store notifica cambios.
///
/// Se elige `InheritedNotifier` en lugar de un paquete externo de gestión de
/// estado porque el store ya es un `ChangeNotifier`: el `InheritedNotifier`
/// resuelve el mismo problema sin añadir dependencias.
class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({
    required AppStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  /// Acceso al store. Lanza un `FlutterError` si el widget está fuera del
  /// [AppScope], que es un fallo de composición y no de ejecución.
  static AppStore of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No se encontró un AppScope en el árbol de widgets.');
    return scope!.notifier!;
  }

  /// Acceso al store sin registrar dependencia, para manejadores de eventos
  /// (pulsaciones) donde no hace falta reconstruir el widget.
  static AppStore read(BuildContext context) {
    final AppScope? scope =
        context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No se encontró un AppScope en el árbol de widgets.');
    return scope!.notifier!;
  }
}