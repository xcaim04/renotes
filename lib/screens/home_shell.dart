import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scope.dart';
import 'buscar_screen.dart';
import 'etiquetas_screen.dart';
import 'proyectos_screen.dart';

/// Contenedor principal con la barra de navegación inferior de tres destinos.
///
/// Las tres pantallas viven en un [IndexedStack] para que cada pestaña conserve
/// su posición de scroll, su texto de búsqueda y sus filtros al alternar entre
/// ellas, como pide el requisito de navegación.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final AppStore store = AppScope.of(context);

    return Scaffold(
      body: IndexedStack(
        index: store.pestanaActual,
        children: const <Widget>[
          ProyectosScreen(),
          BuscarScreen(),
          EtiquetasScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: store.pestanaActual,
          onTap: store.irAPestana,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Proyectos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sell_outlined),
              activeIcon: Icon(Icons.sell_rounded),
              label: 'Etiquetas',
            ),
          ],
        ),
      ),
    );
  }
}

/// AppBar con el título de ReNotes y el conmutador de tema.
///
/// El botón alterna entre los dos temas y muestra siempre el tema al que se
/// cambia, que es la convención que menos confunde.
class BarraReNotes extends StatelessWidget implements PreferredSizeWidget {
  const BarraReNotes({
    this.titulo,
    this.subtitulo,
    this.acciones = const <Widget>[],
    super.key,
  });

  final String? titulo;
  final String? subtitulo;
  final List<Widget> acciones;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final AppStore store = AppScope.of(context);
    final bool oscuro = store.tema == ThemeMode.dark;
    final List<Widget> botones = <Widget>[
      IconButton(
        tooltip: oscuro ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
        onPressed: store.alternarTema,
        icon: Icon(oscuro ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      ),
      ...acciones,
    ];

    return AppBar(
      titleSpacing: Insets.md,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(titulo ?? 'ReNotes'),
          if (subtitulo != null)
            Text(
              subtitulo!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      actions: <Widget>[
        ...botones,
        const SizedBox(width: Insets.sm),
      ],
    );
  }
}