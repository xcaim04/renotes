import 'dart:ui' show Color;

import '../../utils/text_utils.dart';

/// Proyecto de investigación: contenedor de notas.
///
/// Inmutable: el store de la app crea una copia nueva en cada mutación para que
/// `ChangeNotifier` notifique el cambio de forma explícita.
class Proyecto {
  const Proyecto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.creadoEn,
    required this.modificadoEn,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final DateTime creadoEn;
  final DateTime modificadoEn;

  Proyecto copyWith({
    String? nombre,
    String? descripcion,
    DateTime? creadoEn,
    DateTime? modificadoEn,
  }) {
    return Proyecto(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      creadoEn: creadoEn ?? this.creadoEn,
      modificadoEn: modificadoEn ?? this.modificadoEn,
    );
  }

  /// El nombre es obligatorio (RF1). La comparación ignora espacios sobrantes.
  bool get tieneNombre => nombre.trim().isNotEmpty;

  /// Coincidencia por nombre o descripción, insensible a acentos.
  bool coincideCon(String consulta) =>
      contieneIgnorandoAcentos(nombre, consulta) ||
      contieneIgnorandoAcentos(descripcion, consulta);

  @override
  bool operator ==(Object other) => other is Proyecto && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Nota de investigación: pertenece a un único proyecto y puede arrastrar
/// cualquier cantidad de etiquetas globales.
class Nota {
  const Nota({
    required this.id,
    required this.proyectoId,
    required this.titulo,
    required this.descripcion,
    required this.creadoEn,
    required this.modificadoEn,
    this.etiquetasIds = const <String>{},
  });

  final String id;
  final String proyectoId;
  final String titulo;
  final String descripcion;
  final DateTime creadoEn;
  final DateTime modificadoEn;

  /// Ids de [Etiqueta]. Es un `Set` porque el orden no importa y evita duplicados
  /// accidentales al asignar dos veces la misma etiqueta.
  final Set<String> etiquetasIds;

  Nota copyWith({
    String? proyectoId,
    String? titulo,
    String? descripcion,
    DateTime? creadoEn,
    DateTime? modificadoEn,
    Set<String>? etiquetasIds,
  }) {
    return Nota(
      id: id,
      proyectoId: proyectoId ?? this.proyectoId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      creadoEn: creadoEn ?? this.creadoEn,
      modificadoEn: modificadoEn ?? this.modificadoEn,
      etiquetasIds: etiquetasIds ?? this.etiquetasIds,
    );
  }

  /// El título es obligatorio; la descripción puede quedar vacía.
  bool get tieneTitulo => titulo.trim().isNotEmpty;

  /// RFC: el título es obligatorio, la descripción acepta vacíos.
  bool get esValida => tieneTitulo;

  bool tieneEtiqueta(String etiquetaId) => etiquetasIds.contains(etiquetaId);

  /// Búsqueda por título **o** contenido dentro de una nota.
  bool coincideCon(String consulta) =>
      contieneIgnorandoAcentos(titulo, consulta) ||
      contieneIgnorandoAcentos(descripcion, consulta);

  /// Extracto de la descripción para listados; cae al título cuando la nota aún
  /// no tiene cuerpo, para que la fila nunca quede visualmente vacía.
  String extracto({int maximo = 180}) {
    final String cuerpo = descripcion.trim();
    if (cuerpo.isEmpty) {
      return 'Sin descripción todavía';
    }
    return extractoTexto(cuerpo, maximo: maximo);
  }

  @override
  bool operator ==(Object other) => other is Nota && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Etiqueta global: no pertenece a ningún proyecto y se reutiliza entre notas de
/// proyectos distintos.
class Etiqueta {
  const Etiqueta({required this.id, required this.nombre, this.color});

  final String id;
  final String nombre;

  /// Tono opcional asociado (0xAARRGGBB). La paleta visual se deriva del id
  /// cuando es `null`, de modo que cada etiqueta conserva siempre un color.
  final Color? color;

  Etiqueta copyWith({String? nombre, Color? color}) {
    return Etiqueta(
      id: id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
    );
  }

  /// Clave de unicidad: sin acentos, minúsculas y sin espacios sobrantes.
  /// «Metodología», «metodologia» y «METODOLOGIA » son la misma etiqueta.
  String get clave => normalizar(nombre);

  bool coincideCon(String consulta) => contieneIgnorandoAcentos(nombre, consulta);

  @override
  bool operator ==(Object other) => other is Etiqueta && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Criterio de agrupación cuando el usuario selecciona varias etiquetas en la
/// pantalla Etiquetas.
enum ModoAgrupacion {
  /// La nota debe tener **todas** las etiquetas elegidas.
  todas,

  /// La nota debe tener **al menos una** de las etiquetas elegidas.
  alguna;

  String get etiqueta => this == ModoAgrupacion.todas ? 'Todas' : 'Al menos una';
}

/// Estado de un filtro por etiquetas, compartido por la pantalla de notas de un
/// proyecto, la pantalla de etiquetas y la búsqueda global.
class FiltroEtiquetas {
  const FiltroEtiquetas({
    this.seleccionadas = const <String>{},
    this.modo = ModoAgrupacion.todas,
  });

  final Set<String> seleccionadas;
  final ModoAgrupacion modo;

  bool get activo => seleccionadas.isNotEmpty;

  bool contiene(String etiquetaId) => seleccionadas.contains(etiquetaId);

  FiltroEtiquetas copyWith({
    Set<String>? seleccionadas,
    ModoAgrupacion? modo,
  }) {
    return FiltroEtiquetas(
      seleccionadas: seleccionadas ?? this.seleccionadas,
      modo: modo ?? this.modo,
    );
  }

  FiltroEtiquetas alternar(String etiquetaId) {
    final Set<String> siguiente = Set<String>.of(seleccionadas);
    if (!siguiente.remove(etiquetaId)) {
      siguiente.add(etiquetaId);
    }
    return copyWith(seleccionadas: siguiente);
  }

  FiltroEtiquetas limpiar() => const FiltroEtiquetas();

  /// `true` cuando [nota] cumple el filtro.
  bool satisface(Nota nota) {
    if (seleccionadas.isEmpty) {
      return true;
    }
    final Set<String> comunes = nota.etiquetasIds.intersection(seleccionadas);
    return modo == ModoAgrupacion.todas
        ? comunes.length == seleccionadas.length
        : comunes.isNotEmpty;
  }
}