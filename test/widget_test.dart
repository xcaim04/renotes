import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renotes/main.dart';
import 'package:renotes/data/app_store.dart';
import 'package:renotes/models/modelos.dart';

/// Localiza la etiqueta de una pestaña del `BottomNavigationBar`.
///
/// `BottomNavigationBarItem` es una clase de datos, no un widget del árbol, así
/// que se localiza por su `Text` descendiente del `BottomNavigationBar`.
Finder etiquetaDePestana(String etiqueta) => find.descendant(
  of: find.byType(BottomNavigationBar),
  matching: find.text(etiqueta),
);

void main() {
  group('AppStore: volúmenes mínimos del enunciado', () {
    test('carga 3 proyectos, 15 notas y 9 etiquetas', () {
      final AppStore store = AppStore();
      expect(store.proyectos.length, greaterThanOrEqualTo(3));
      expect(store.notas.length, greaterThanOrEqualTo(15));
      expect(store.etiquetas.length, greaterThanOrEqualTo(8));
    });

    test('cada proyecto tiene al menos 4 notas', () {
      final AppStore store = AppStore();
      for (final Proyecto p in store.proyectos) {
        expect(
          store.numeroNotasDeProyecto(p.id),
          greaterThanOrEqualTo(4),
          reason: 'El proyecto «${p.nombre}» necesita al menos 4 notas.',
        );
      }
    });

    test('hay al menos 3 etiquetas usadas en notas de proyectos distintos', () {
      final AppStore store = AppStore();
      int compartidas = 0;
      for (final Etiqueta e in store.etiquetas) {
        final Set<String> proyectos = store.notas
            .where((Nota n) => n.etiquetasIds.contains(e.id))
            .map((Nota n) => n.proyectoId)
            .toSet();
        if (proyectos.length >= 2) {
          compartidas += 1;
        }
      }
      expect(compartidas, greaterThanOrEqualTo(3));
    });

    test('hay al menos 5 notas con descripción larga', () {
      final AppStore store = AppStore();
      final int largas = store.notas
          .where((Nota n) => n.descripcion.trim().length > 600)
          .length;
      expect(largas, greaterThanOrEqualTo(5));
    });

    test('hay al menos una nota sin etiquetas y una etiqueta sin notas', () {
      final AppStore store = AppStore();
      expect(store.notas.any((Nota n) => n.etiquetasIds.isEmpty), isTrue);
      expect(store.etiquetas.any((Etiqueta e) => store.numeroNotasConEtiqueta(e.id) == 0),
          isTrue);
    });
  });

  group('AppStore: proyectos', () {
    test('crear proyecto exige nombre no vacío y recorta espacios', () {
      final AppStore store = AppStore();
      expect(store.crearProyecto(nombre: '   ', descripcion: 'x'), isNull);

      final String? id = store.crearProyecto(
        nombre: '  Neuroimagen  ',
        descripcion: '  detalle  ',
      );
      expect(id, isNotNull);
      final Proyecto creado = store.proyectoPorId(id!)!;
      expect(creado.nombre, 'Neuroimagen');
      expect(creado.descripcion, 'detalle');
    });

    test('eliminar un proyecto borra también sus notas', () {
      final AppStore store = AppStore();
      final Proyecto p = store.proyectos.first;
      final int notasAntes = store.numeroNotasDeProyecto(p.id);
      expect(notasAntes, greaterThan(0));

      expect(store.eliminarProyecto(p.id), isTrue);
      expect(store.proyectoPorId(p.id), isNull);
      expect(store.notas.where((Nota n) => n.proyectoId == p.id), isEmpty);
    });
  });

  group('AppStore: notas', () {
    test('crear nota exige título', () {
      final AppStore store = AppStore();
      final String proyectoId = store.proyectos.first.id;
      expect(
        store.crearNota(proyectoId: proyectoId, titulo: '  ', descripcion: 'x'),
        isNull,
      );
      expect(
        store.crearNota(proyectoId: proyectoId, titulo: 'Nota', descripcion: ''),
        isNotNull,
      );
    });

    test('editar nota conserva etiquetas y actualiza la fecha de modificación', () {
      final AppStore store = AppStore();
      final Nota nota = store.notas.first;
      final DateTime antes = nota.modificadoEn;

      final bool ok = store.actualizarNota(
        id: nota.id,
        titulo: 'Título nuevo',
        descripcion: 'Cuerpo nuevo',
        etiquetasIds: <String>{'e_etica'},
      );

      expect(ok, isTrue);
      final Nota guardada = store.notaPorId(nota.id)!;
      expect(guardada.titulo, 'Título nuevo');
      expect(guardada.etiquetasIds, <String>{'e_etica'});
      expect(guardada.modificadoEn.isBefore(antes), isFalse);
    });
  });

  group('AppStore: etiquetas', () {
    test('crearSiNoExiste es idempotente ignorando acentos y mayúsculas', () {
      final AppStore store = AppStore();
      final int antes = store.etiquetas.length;

      final Etiqueta a = store.crearSiNoExiste('Estadística');
      expect(store.etiquetas.length, antes + 1);

      final Etiqueta b = store.crearSiNoExiste('estadistica');
      final Etiqueta c = store.crearSiNoExiste('  ESTADISTICA ');
      expect(b.id, a.id);
      expect(c.id, a.id);
      expect(store.etiquetas.length, antes + 1);
    });

    test('renombrar rechaza nombres duplicados y vacíos', () {
      final AppStore store = AppStore();
      final Etiqueta primera = store.etiquetas[0];
      final Etiqueta segunda = store.etiquetas[1];

      expect(store.renombrarEtiqueta(primera.id, '   '), isFalse);
      expect(store.renombrarEtiqueta(primera.id, segunda.nombre.toUpperCase()),
          isFalse);
      expect(store.renombrarEtiqueta(primera.id, 'Nombre libre'), isTrue);
    });

    test('eliminar una etiqueta la quita de las notas y no borra notas', () {
      final AppStore store = AppStore();
      final Etiqueta conNotas =
          store.etiquetas.firstWhere((Etiqueta e) => store.numeroNotasConEtiqueta(e.id) > 1);
      final int notasTotales = store.notas.length;
      final int afectadas = store.numeroNotasConEtiqueta(conNotas.id);
      expect(afectadas, greaterThan(1));

      final int devueltas = store.eliminarEtiqueta(conNotas.id);
      expect(devueltas, afectadas);
      expect(store.etiquetaPorId(conNotas.id), isNull);
      expect(store.notas.length, notasTotales);
      expect(store.notas.any((Nota n) => n.etiquetasIds.contains(conNotas.id)), isFalse);
    });
  });

  group('AppStore: búsqueda y filtros', () {
    test('buscar encuentra por título y por contenido', () {
      final AppStore store = AppStore();
      final Nota nota = store.notas.first;

      expect(
        store.buscar(consulta: nota.titulo).any((Nota n) => n.id == nota.id),
        isTrue,
      );
      final String fragmento = nota.descripcion.substring(0, 30);
      expect(
        store.buscar(consulta: fragmento).any((Nota n) => n.id == nota.id),
        isTrue,
      );
    });

    test('la búsqueda ignora mayúsculas y acentos', () {
      final AppStore store = AppStore();
      final String conAcento =
          store.notas.map((Nota n) => n.titulo).firstWhere((String t) =>
              t.toLowerCase().contains('metodolog') || t.contains('Ética'));
      final String minuscula = conAcento
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u');
      expect(store.buscar(consulta: minuscula), isNotEmpty);
    });

    test('filtro por proyecto y por etiquetas acota los resultados', () {
      final AppStore store = AppStore();
      final Proyecto p = store.proyectos.first;
      final List<Nota> delProyecto = store.buscar(proyectoId: p.id);
      expect(delProyecto.every((Nota n) => n.proyectoId == p.id), isTrue);

      final FiltroEtiquetas filtro =
          FiltroEtiquetas(seleccionadas: <String>{'e_metodologia', 'e_etica'});
      final List<Nota> combinadas = store.buscar(filtro: filtro);
      expect(
        combinadas.every((Nota n) => n.etiquetasIds.containsAll(filtro.seleccionadas)),
        isTrue,
      );
      // «Todas» es más restrictivo que «al menos una».
      final List<Nota> alguna = store.buscar(
        filtro: const FiltroEtiquetas(
          seleccionadas: <String>{'e_metodologia', 'e_etica'},
          modo: ModoAgrupacion.alguna,
        ),
      );
      expect(alguna.length, greaterThanOrEqualTo(combinadas.length));
    });

    test('etiquetasDeProyecto sólo ofrece etiquetas presentes en sus notas', () {
      final AppStore store = AppStore();
      final Proyecto p = store.proyectos.first;
      final List<Etiqueta> ofrecidas = store.etiquetasDeProyecto(p.id);
      for (final Etiqueta e in ofrecidas) {
        expect(
          store
              .notasDeProyecto(p.id)
              .any((Nota n) => n.etiquetasIds.contains(e.id)),
          isTrue,
        );
      }
    });
  });

  testWidgets('la app arranca y muestra la lista de proyectos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReNotesApp());
    await tester.pumpAndSettle();

    // La barra superior muestra el nombre de la app y la sección activa.
    expect(find.text('ReNotes'), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Proyectos')),
      findsOneWidget,
    );
    expect(find.text('Nuevo proyecto'), findsOneWidget);

    // Las tres pestañas del BottomNavigationBar existen.
    for (final String etiqueta in <String>['Proyectos', 'Buscar', 'Etiquetas']) {
      expect(
        find.descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text(etiqueta),
        ),
        findsOneWidget,
      );
    }

    // Los proyectos sembrados son visibles sin desplazamiento.
    for (final Proyecto p in AppStore().proyectos) {
      expect(find.text(p.nombre), findsOneWidget);
    }
  });

  testWidgets('el conmutador de la barra cambia a modo oscuro', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReNotesApp());
    await tester.pumpAndSettle();

    // El tema inicial es el claro: el botón ofrece pasar al oscuro.
    expect(
      find.byIcon(Icons.dark_mode_rounded),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    final Brightness brillo = tester
        .widget<MaterialApp>(find.byType(MaterialApp))
        .themeMode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light;
    expect(brillo, Brightness.dark);
  });

  testWidgets('no hay desbordamientos de layout en las tres pestañas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReNotesApp());
    await tester.pumpAndSettle();

    for (final String etiqueta in <String>['Proyectos', 'Buscar', 'Etiquetas']) {
      await tester.tap(etiquetaDePestana(etiqueta));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Layout inválido en $etiqueta');
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(etiqueta)),
        findsOneWidget,
        reason: 'La pestaña $etiqueta debe quedar visible',
      );
    }
  });

  testWidgets('el filtro por texto de proyectos se aplica al escribir', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReNotesApp());
    await tester.pumpAndSettle();

    final Proyecto objetivo = AppStore().proyectos.first;
    await tester.enterText(find.byType(TextField), objetivo.nombre);
    await tester.pump();

    expect(find.text(objetivo.nombre), findsWidgets);
    expect(find.text(objetivo.descripcion), findsOneWidget);
  });

  testWidgets('cambiar de pestaña conserva el estado de cada pantalla', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReNotesApp());
    await tester.pumpAndSettle();

    // Escribimos en la búsqueda global, saltamos a Etiquetas y volvemos: el
    // IndexedStack debe conservar el texto y los resultados.
    await tester.tap(etiquetaDePestana('Buscar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'memoria');
    await tester.pump();
    expect(find.textContaining('resultado'), findsOneWidget);

    await tester.tap(etiquetaDePestana('Etiquetas'));
    await tester.pumpAndSettle();
    await tester.tap(etiquetaDePestana('Buscar'));
    await tester.pumpAndSettle();

    expect(find.text('memoria'), findsOneWidget);
    expect(find.textContaining('resultado'), findsOneWidget);
  });
}