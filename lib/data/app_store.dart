import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/foundation.dart';

import '../models/modelos.dart';
import '../utils/text_utils.dart';
import 'datos_iniciales.dart';

/// Fuente única de verdad de la aplicación.
///
/// ReNotes guarda todo en memoria, así que este store es a la vez el modelo y
/// el «servicio»: no hay base de datos ni capa de red. Cada método público
/// muta una copia inmutable de la lista afectada y llama a [notifyListeners];
/// las pantallas escuchan con `AnimatedBuilder`/`ListenableBuilder` a través de
/// [AppScope].
class AppStore extends ChangeNotifier {
  AppStore({DateTime? ahora}) : _ahora = ahora ?? DateTime.now() {
    _proyectos = DatosIniciales.proyectos(_ahora);
    _etiquetas = DatosIniciales.etiquetas();
    _notas = DatosIniciales.notas(_ahora);
  }

  final DateTime _ahora;
  int _secuencia = 0;

  late List<Proyecto> _proyectos;
  late List<Etiqueta> _etiquetas;
  late List<Nota> _notas;

  ThemeMode _tema = ThemeMode.light;
  int _pestanaActual = 0;

  ThemeMode get tema => _tema;
  int get pestanaActual => _pestanaActual;

  // ------------------------------------------------------------- Lectura

  List<Proyecto> get proyectos => List<Proyecto>.unmodifiable(_proyectos);

  List<Etiqueta> get etiquetas => List<Etiqueta>.unmodifiable(_etiquetas);

  List<Nota> get notas => List<Nota>.unmodifiable(_notas);

  Proyecto? proyectoPorId(String id) {
    for (final Proyecto p in _proyectos) {
      if (p.id == id) {
        return p;
      }
    }
    return null;
  }

  Nota? notaPorId(String id) {
    for (final Nota n in _notas) {
      if (n.id == id) {
        return n;
      }
    }
    return null;
  }

  Etiqueta? etiquetaPorId(String id) {
    for (final Etiqueta e in _etiquetas) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  /// Notas de un proyecto, de la más reciente a la más antigua.
  List<Nota> notasDeProyecto(String proyectoId) {
    final List<Nota> resultado = _notas
        .where((Nota n) => n.proyectoId == proyectoId)
        .toList();
    resultado.sort((Nota a, Nota b) => b.modificadoEn.compareTo(a.modificadoEn));
    return resultado;
  }

  int numeroNotasDeProyecto(String proyectoId) =>
      _notas.where((Nota n) => n.proyectoId == proyectoId).length;

  /// Etiquetas que aparecen en al menos una nota del proyecto. Es el catálogo
  /// que alimenta el filtro de la pantalla de notas: ofrecer una etiqueta que no
  /// aparece allí produciría un filtro que siempre devuelve vacío.
  List<Etiqueta> etiquetasDeProyecto(String proyectoId) {
    final Set<String> enUso = <String>{};
    for (final Nota n in _notas) {
      if (n.proyectoId == proyectoId) {
        enUso.addAll(n.etiquetasIds);
      }
    }
    final List<Etiqueta> resultado = _etiquetas
        .where((Etiqueta e) => enUso.contains(e.id))
        .toList();
    resultado.sort((Etiqueta a, Etiqueta b) =>
        a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
    return resultado;
  }

  /// Cuántas notas de **todos** los proyectos llevan esta etiqueta.
  int numeroNotasConEtiqueta(String etiquetaId) =>
      _notas.where((Nota n) => n.etiquetasIds.contains(etiquetaId)).length;

  List<Nota> notasConEtiqueta(String etiquetaId) {
    final List<Nota> resultado =
        _notas.where((Nota n) => n.etiquetasIds.contains(etiquetaId)).toList();
    resultado.sort((Nota a, Nota b) => b.modificadoEn.compareTo(a.modificadoEn));
    return resultado;
  }

  // -------------------------------------------------------------- Proyectos

  /// Crea un proyecto. Devuelve el id generado, o `null` si el nombre está vacío.
  String? crearProyecto({
    required String nombre,
    required String descripcion,
  }) {
    final String limpio = nombre.trim();
    if (limpio.isEmpty) {
      return null;
    }
    final String id = _nuevoId('p');
    _proyectos = <Proyecto>[
      ..._proyectos,
      Proyecto(
        id: id,
        nombre: limpio,
        descripcion: descripcion.trim(),
        creadoEn: _ahora,
        modificadoEn: _ahora,
      ),
    ];
    notifyListeners();
    return id;
  }

  /// Actualiza nombre y descripción. El nombre no puede quedar vacío.
  bool actualizarProyecto({
    required String id,
    required String nombre,
    required String descripcion,
  }) {
    final String limpio = nombre.trim();
    if (limpio.isEmpty) {
      return false;
    }
    final int indice = _proyectos.indexWhere((Proyecto p) => p.id == id);
    if (indice < 0) {
      return false;
    }
    _proyectos = List<Proyecto>.of(_proyectos)
      ..[indice] = _proyectos[indice].copyWith(
        nombre: limpio,
        descripcion: descripcion.trim(),
        modificadoEn: _ahora,
      );
    notifyListeners();
    return true;
  }

  /// Elimina un proyecto **y todas sus notas** (RF1). Las etiquetas no se tocan:
  /// son globales y pueden seguir usándose en otros proyectos.
  bool eliminarProyecto(String id) {
    final int antes = _proyectos.length;
    _proyectos = _proyectos.where((Proyecto p) => p.id != id).toList();
    if (_proyectos.length == antes) {
      return false;
    }
    _notas = _notas.where((Nota n) => n.proyectoId != id).toList();
    notifyListeners();
    return true;
  }

  // ----------------------------------------------------------------- Notas

  /// Crea una nota. Devuelve el id generado, o `null` si falta el título.
  String? crearNota({
    required String proyectoId,
    required String titulo,
    required String descripcion,
    Set<String> etiquetasIds = const <String>{},
  }) {
    if (titulo.trim().isEmpty) {
      return null;
    }
    final String id = _nuevoId('n');
    _notas = <Nota>[
      ..._notas,
      Nota(
        id: id,
        proyectoId: proyectoId,
        titulo: titulo.trim(),
        descripcion: descripcion.trim(),
        creadoEn: _ahora,
        modificadoEn: _ahora,
        etiquetasIds: Set<String>.of(etiquetasIds),
      ),
    ];
    _marcarProyectoModificado(proyectoId);
    notifyListeners();
    return id;
  }

  /// Guarda una nota existente. Devuelve `false` si el título queda vacío.
  bool actualizarNota({
    required String id,
    required String titulo,
    required String descripcion,
    required Set<String> etiquetasIds,
  }) {
    if (titulo.trim().isEmpty) {
      return false;
    }
    final int indice = _notas.indexWhere((Nota n) => n.id == id);
    if (indice < 0) {
      return false;
    }
    final Nota anterior = _notas[indice];
    _notas = List<Nota>.of(_notas)
      ..[indice] = anterior.copyWith(
        titulo: titulo.trim(),
        descripcion: descripcion.trim(),
        etiquetasIds: Set<String>.of(etiquetasIds),
        modificadoEn: _ahora,
      );
    _marcarProyectoModificado(anterior.proyectoId);
    notifyListeners();
    return true;
  }

  bool eliminarNota(String id) {
    final int indice = _notas.indexWhere((Nota n) => n.id == id);
    if (indice < 0) {
      return false;
    }
    final String proyectoId = _notas[indice].proyectoId;
    _notas = List<Nota>.of(_notas)..removeAt(indice);
    _marcarProyectoModificado(proyectoId);
    notifyListeners();
    return true;
  }

  // ------------------------------------------------------------- Etiquetas

  /// Busca una etiqueta por nombre ignorando mayúsculas, acentos y espacios.
  Etiqueta? etiquetaConNombre(String nombre) {
    final String clave = normalizar(nombre);
    for (final Etiqueta e in _etiquetas) {
      if (e.clave == clave) {
        return e;
      }
    }
    return null;
  }

  /// Crea una etiqueta si el nombre no existe todavía. Devuelve la etiqueta
  /// resultante: la recién creada o la existente, para que el editor pueda
  /// asignarla sin distinguir los dos casos.
  Etiqueta crearSiNoExiste(String nombre) {
    final Etiqueta? existente = etiquetaConNombre(nombre);
    if (existente != null) {
      return existente;
    }
    final String limpio = nombre.trim();
    final Etiqueta nueva = Etiqueta(id: _nuevoId('e'), nombre: limpio);
    _etiquetas = <Etiqueta>[..._etiquetas, nueva];
    notifyListeners();
    return nueva;
  }

  /// Renombra una etiqueta. Devuelve `false` si el nombre queda vacío, si no
  /// existe la etiqueta o si el nombre nuevo choca con otra etiqueta existente
  /// (la comparación ignora acentos y mayúsculas).
  bool renombrarEtiqueta(String id, String nombre) {
    final String limpio = nombre.trim();
    if (limpio.isEmpty) {
      return false;
    }
    final int indice = _etiquetas.indexWhere((Etiqueta e) => e.id == id);
    if (indice < 0) {
      return false;
    }
    final String clave = normalizar(limpio);
    final bool choca = _etiquetas.any(
      (Etiqueta e) => e.id != id && e.clave == clave,
    );
    if (choca) {
      return false;
    }
    _etiquetas = List<Etiqueta>.of(_etiquetas)
      ..[indice] = _etiquetas[indice].copyWith(nombre: limpio);
    notifyListeners();
    return true;
  }

  /// Elimina una etiqueta y la quita de todas las notas que la usaban.
  /// Devuelve cuántas notas se vio afectado, para poder confirmarlo en el diálogo.
  int eliminarEtiqueta(String id) {
    final int notasAfectadas = numeroNotasConEtiqueta(id);
    _etiquetas = _etiquetas.where((Etiqueta e) => e.id != id).toList();
    _notas = _notas
        .map(
          (Nota n) => n.etiquetasIds.contains(id)
              ? n.copyWith(
                  etiquetasIds: (Set<String>.of(n.etiquetasIds)..remove(id)),
                  modificadoEn: _ahora,
                )
              : n,
        )
        .toList();
    notifyListeners();
    return notasAfectadas;
  }

  // --------------------------------------------------------- Búsqueda global

  /// Búsqueda por título o contenido en todos los proyectos, con filtros
  /// opcionales de proyecto y etiquetas (RF6).
  List<Nota> buscar({
    String consulta = '',
    String? proyectoId,
    FiltroEtiquetas filtro = const FiltroEtiquetas(),
  }) {
    final List<Nota> resultado = _notas.where((Nota n) {
      if (proyectoId != null && n.proyectoId != proyectoId) {
        return false;
      }
      if (!filtro.satisface(n)) {
        return false;
      }
      return n.coincideCon(consulta);
    }).toList();
    resultado.sort((Nota a, Nota b) => b.modificadoEn.compareTo(a.modificadoEn));
    return resultado;
  }

  /// Notas de un proyecto que cumplen la búsqueda interna y el filtro de
  /// etiquetas (RF2).
  List<Nota> notasDeProyectoFiltradas({
    required String proyectoId,
    String consulta = '',
    FiltroEtiquetas filtro = const FiltroEtiquetas(),
  }) {
    return notasDeProyecto(proyectoId).where((Nota n) {
      if (!filtro.satisface(n)) {
        return false;
      }
      return n.coincideCon(consulta);
    }).toList();
  }

  // ------------------------------------------------------------ Preferencia

  void cambiarTema(ThemeMode modo) {
    if (_tema == modo) {
      return;
    }
    _tema = modo;
    notifyListeners();
  }

  void alternarTema() {
    cambiarTema(_tema == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void irAPestana(int indice) {
    if (_pestanaActual == indice) {
      return;
    }
    _pestanaActual = indice;
    notifyListeners();
  }

  // ------------------------------------------------------------- Auxiliares

  void _marcarProyectoModificado(String proyectoId) {
    final int indice =
        _proyectos.indexWhere((Proyecto p) => p.id == proyectoId);
    if (indice < 0) {
      return;
    }
    _proyectos = List<Proyecto>.of(_proyectos)
      ..[indice] = _proyectos[indice].copyWith(modificadoEn: _ahora);
  }

  String _nuevoId(String prefijo) {
    _secuencia += 1;
    return '${prefijo}_${_ahora.microsecondsSinceEpoch}_$_secuencia';
  }
}