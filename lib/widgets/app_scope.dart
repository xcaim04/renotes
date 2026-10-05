import 'package:flutter/material.dart';

import '../data/app_store.dart';

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({
    required AppStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static AppStore of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No se encontró un AppScope en el árbol de widgets.');
    return scope!.notifier!;
  }

  
  static AppStore read(BuildContext context) {
    final AppScope? scope =
        context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No se encontró un AppScope en el árbol de widgets.');
    return scope!.notifier!;
  }
}