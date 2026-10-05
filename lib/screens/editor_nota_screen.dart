import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../models/modelos.dart';
import '../theme/app_theme.dart';
import '../utils/text_utils.dart';
import '../widgets/app_scope.dart';
import '../widgets/widgets_comunes.dart';

/// Campo de entrada de etiquetas con autocompletado y creación al vuelo.
///
/// Se usa [RawAutocomplete] porque el proyecto sólo admite widgets del SDK de
/// Flutter. Requisitos que resuelve este campo:
///
/// * las sugerencias ignoran mayúsculas, minúsculas, acentos y espacios;
/// * se ofrecen etiquetas de **todos** los proyectos, no sólo del actual;
/// * se excluyen las que ya están asignadas a la nota;
/// * si no hay coincidencia exacta se ofrece crearla;
/// * se confirma con la tecla Intro, con la coma o al pulsar una sugerencia;
/// * tras asignar, el campo queda limpio para seguir escribiendo.
class CampoEtiqueta extends StatefulWidget {
  const CampoEtiqueta({
    required this.asignadasIds,
    required this.onAsignar,
    required this.onQuitar,
    super.key,
  });

  final Set<String> asignadasIds;
  final ValueChanged<Etiqueta> onAsignar;
  final ValueChanged<Etiqueta> onQuitar;

  @override
  State<CampoEtiqueta> createState() => _CampoEtiquetaState();
}

class _CampoEtiquetaState extends State<CampoEtiqueta> {
  final TextEditingController _controlador = TextEditingController();
  final FocusNode _foco = FocusNode();

  @override
  void dispose() {
    _controlador.dispose();
    _foco.dispose();
    super.dispose();
  }

  /// Sugerencias para la consulta actual: subcadena sobre la clave normalizada,
  /// ordenadas por longitud de nombre (las más cortas primero) y sin las ya
  /// asignadas.
  List<Etiqueta> _candidatas(String consulta) {
    final AppStore store = AppScope.read(context);
    final List<Etiqueta> resultado = store.etiquetas
        .where((Etiqueta e) => !widget.asignadasIds.contains(e.id))
        .where((Etiqueta e) => e.coincideCon(consulta))
        .toList()
      ..sort((Etiqueta a, Etiqueta b) {
        final int porLongitud = a.nombre.length.compareTo(b.nombre.length);
        return porLongitud != 0
            ? porLongitud
            : a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      });
    return resultado;
  }

  /// Búsqueda pura: etiqueta ya existente cuyo nombre normalizado coincide con
  /// [texto] y que aún no está asignada. No modifica nada, así que puede
  /// llamarse durante el build para decidir si hay que ofrecer «crear».
  Etiqueta? _coincidenciaExacta(String texto) {
    final String limpio = texto.trim();
    if (limpio.isEmpty) {
      return null;
    }
    final String clave = normalizar(limpio);
    for (final Etiqueta e in AppScope.read(context).etiquetas) {
      if (!widget.asignadasIds.contains(e.id) && e.clave == clave) {
        return e;
      }
    }
    return null;
  }

  /// Asigna la etiqueta que ya existe con ese nombre. Devuelve `true` si la
  /// encontró, para que quien llama sepa si debe recurrir a crearla.
  bool _asignarSiExiste(String texto) {
    final Etiqueta? coincidente = _coincidenciaExacta(texto);
    if (coincidente == null) {
      return false;
    }
    widget.onAsignar(coincidente);
    return true;
  }

  /// Enter o coma: intenta reutilizar una etiqueta existente y, si no existe,
  /// la crea. Siempre limpia el campo para permitir encadenar varias.
  void _confirmarTexto() {
    final String texto = _controlador.text.trim();
    if (texto.isEmpty) {
      return;
    }
    if (!_asignarSiExiste(texto)) {
      final AppStore store = AppScope.read(context);
      widget.onAsignar(store.crearSiNoExiste(texto));
    }
    _limpiar();
  }

  /// Vacía el campo para poder encadenar otra etiqueta. `RawAutocomplete`
  /// recalcula las sugerencias al cambiar el texto del controlador, así que no
  /// hace falta forzar ninguna actualización manual.
  void _limpiar() {
    _controlador.clear();
    _foco.requestFocus();
  }

  void _elegir(Etiqueta etiqueta) {
    widget.onAsignar(etiqueta);
    _limpiar();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<Etiqueta>(
      textEditingController: _controlador,
      focusNode: _foco,
      optionsBuilder: (TextEditingValue valor) => _candidatas(valor.text),
      displayStringForOption: (Etiqueta e) => e.nombre,
      onSelected: _elegir,
      fieldViewBuilder: (
        BuildContext contexto,
        TextEditingController controlador,
        FocusNode nodoFoco,
        VoidCallback onCampoTap,
      ) {
        return TextField(
          controller: controlador,
          focusNode: nodoFoco,
          onTap: onCampoTap,
          onSubmitted: (_) => _confirmarTexto(),
          textInputAction: TextInputAction.done,
          inputFormatters: <TextInputFormatter>[_SeparadorComa(_confirmarTexto)],
          decoration: InputDecoration(
            labelText: 'Etiquetas',
            hintText: 'Escribe y pulsa Intro o coma',
            prefixIcon: const Icon(Icons.sell_outlined, size: 20),
            suffixIcon: _controlador.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Confirmar etiqueta',
                    icon: const Icon(Icons.add_rounded, size: 18),
                    onPressed: _confirmarTexto,
                  ),
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext contexto,
        AutocompleteOnSelected<Etiqueta> onSelected,
        Iterable<Etiqueta> opciones,
      ) {
        final List<Etiqueta> lista = opciones.toList();
        final String consulta = _controlador.text.trim();
        final bool puedeCrear =
            consulta.isNotEmpty && _coincidenciaExacta(consulta) == null;

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(Corners.lg),
            clipBehavior: Clip.antiAlias,
            color: Theme.of(contexto).colorScheme.surfaceContainerLowest,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280, maxWidth: 420),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: lista.length + (puedeCrear ? 1 : 0),
                itemBuilder: (BuildContext contexto, int indice) {
                  if (indice == lista.length) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.add_circle_outline_rounded, size: 20),
                      title: Text('Crear «$consulta»'),
                      onTap: () {
                        final AppStore store = AppScope.read(contexto);
                        widget.onAsignar(store.crearSiNoExiste(consulta));
                        _limpiar();
                      },
                    );
                  }
                  final Etiqueta etiqueta = lista[indice];
                  return ListTile(
                    dense: true,
                    leading: _PuntoEtiqueta(etiqueta: etiqueta),
                    title: Text(etiqueta.nombre),
                    onTap: () => onSelected(etiqueta),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Detecta la coma y confirma la etiqueta en vez de escribirla.
///
/// Se descarta el carácter separador para que la coma nunca llegue al campo.
class _SeparadorComa extends TextInputFormatter {
  _SeparadorComa(this.alConfirmar);

  final VoidCallback alConfirmar;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) {
    if (!nuevo.text.contains(',')) {
      return nuevo;
    }
    // Se confirma tras el frame para no mutar el campo mientras se construye.
    WidgetsBinding.instance.addPostFrameCallback((_) => alConfirmar());
    final String resto = anterior.text.split(',').last;
    return TextEditingValue(
      text: resto,
      selection: TextSelection.collapsed(offset: resto.length),
    );
  }
}

/// Punto de color de una etiqueta en las sugerencias.
class _PuntoEtiqueta extends StatelessWidget {
  const _PuntoEtiqueta({required this.etiqueta});

  final Etiqueta etiqueta;

  @override
  Widget build(BuildContext context) {
    final TagPalette paleta =
        TagPalette.of(etiqueta.id, Theme.of(context).brightness);
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: paleta.dot, shape: BoxShape.circle),
    );
  }
}

/// RF3. Editor de notas: título obligatorio, descripción larga, etiquetas.
class EditorNotaScreen extends StatefulWidget {
  const EditorNotaScreen({required this.proyectoId, this.notaId, super.key});

  final String proyectoId;

  /// `null` para crear una nota nueva; el id de la nota para editarla.
  final String? notaId;

  @override
  State<EditorNotaScreen> createState() => _EditorNotaScreenState();
}

class _EditorNotaScreenState extends State<EditorNotaScreen> {
  late final TextEditingController _titulo;
  late final TextEditingController _descripcion;
  late Set<String> _etiquetasIds;
  final FocusNode _focoDescripcion = FocusNode();

  String? _errorTitulo;
  bool _guardando = false;

  bool get _editando => widget.notaId != null;

  /// Estado guardado con el que se compara para detectar cambios sin guardar.
  late String _tituloInicial;
  late String _descripcionInicial;
  late Set<String> _etiquetasInicial;

  @override
  void initState() {
    super.initState();
    final Nota? existente = widget.notaId == null
        ? null
        : AppScope.read(context).notaPorId(widget.notaId!);
    _titulo = TextEditingController(text: existente?.titulo ?? '');
    _descripcion = TextEditingController(text: existente?.descripcion ?? '');
    _etiquetasIds = Set<String>.of(existente?.etiquetasIds ?? const <String>{});
    _tituloInicial = _titulo.text;
    _descripcionInicial = _descripcion.text;
    _etiquetasInicial = Set<String>.of(_etiquetasIds);

    // `PopScope` sólo reevalúa `canPop` cuando hay un `setState`, así que los
    // controladores notifican cada pulsación: sin esto, escribir en el cuerpo y
    // salir con el botón atrás no pediría confirmar los cambios.
    _titulo.addListener(_notificarCambios);
    _descripcion.addListener(_notificarCambios);
  }

  void _notificarCambios() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titulo.removeListener(_notificarCambios);
    _descripcion.removeListener(_notificarCambios);
    _titulo.dispose();
    _descripcion.dispose();
    _focoDescripcion.dispose();
    super.dispose();
  }

  bool get _hayCambios =>
      _titulo.text != _tituloInicial ||
      _descripcion.text != _descripcionInicial ||
      !setEquals(_etiquetasIds, _etiquetasInicial);

  static bool setEquals(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  Future<void> _guardar() async {
    if (_titulo.text.trim().isEmpty) {
      setState(() => _errorTitulo = 'El título es obligatorio.');
      return;
    }
    final ScaffoldMessengerState mensajero = ScaffoldMessenger.of(context);
    final NavigatorState navegador = Navigator.of(context);
    final AppStore store = AppScope.read(context);

    setState(() => _guardando = true);
    final bool ok = _editando
        ? store.actualizarNota(
            id: widget.notaId!,
            titulo: _titulo.text,
            descripcion: _descripcion.text,
            etiquetasIds: _etiquetasIds,
          )
        : store.crearNota(
              proyectoId: widget.proyectoId,
              titulo: _titulo.text,
              descripcion: _descripcion.text,
              etiquetasIds: _etiquetasIds,
            ) !=
              null;

    if (!ok) {
      if (!mounted) {
        return;
      }
      setState(() {
        _guardando = false;
        _errorTitulo = 'El título es obligatorio.';
      });
      return;
    }

    // Tras guardar, el estado guardado pasa a ser el actual: así el `PopScope`
    // no vuelve a preguntar al intentar salir.
    _tituloInicial = _titulo.text;
    _descripcionInicial = _descripcion.text;
    _etiquetasInicial = Set<String>.of(_etiquetasIds);
    if (!mounted) {
      return;
    }
    setState(() => _guardando = false);
    mensajero.hideCurrentSnackBar();
    navegador.pop();
  }

  /// Diálogo de cambios sin guardar al intentar salir (RF3).
  Future<bool> _pedirConfirmacion() async {
    final bool descartar = await confirmar(
      context,
      titulo: 'Descartar cambios',
      mensaje:
          'Hay cambios sin guardar en esta nota. Si sales ahora se perderán.',
      confirmarTexto: 'Descartar',
      cancelarTexto: 'Seguir editando',
      icono: Icons.edit_note_rounded,
    );
    return descartar;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppStore store = AppScope.of(context);
    final List<Etiqueta> etiquetas = _etiquetasIds
        .map(store.etiquetaPorId)
        .whereType<Etiqueta>()
        .toList();

    return PopScope<Object?>(
      canPop: !_hayCambios,
      onPopInvokedWithResult: (bool hizoPop, Object? resultado) async {
        if (hizoPop) {
          return;
        }
        final bool descartar = await _pedirConfirmacion();
        if (descartar && mounted && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editando ? 'Editar nota' : 'Nueva nota'),
          actions: <Widget>[
            TextButton(
              onPressed: _guardando ? null : _guardar,
              child: const Text('Guardar'),
            ),
            const SizedBox(width: Insets.sm),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              // El cuerpo de la nota puede ser largo: se desplaza en bloque para
              // que el título y los botones de abajo queden siempre visibles y el
              // teclado no tape los campos.
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    Insets.md,
                    Insets.md,
                    Insets.md,
                    Insets.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        controller: _titulo,
                        autofocus: !_editando,
                        textCapitalization: TextCapitalization.sentences,
                        style: theme.textTheme.headlineSmall,
                        decoration: InputDecoration(
                          labelText: 'Título',
                          hintText: 'Obligatorio',
                          errorText: _errorTitulo,
                        ),
                        onChanged: (_) {
                          if (_errorTitulo != null) {
                            setState(() => _errorTitulo = null);
                          }
                        },
                        onSubmitted: (_) => _focoDescripcion.requestFocus(),
                      ),
                      const SizedBox(height: Insets.md),
                      TextField(
                        controller: _descripcion,
                        focusNode: _focoDescripcion,
                        minLines: 8,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: theme.textTheme.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          hintText:
                              'Escribe el contenido de la nota. Puede ser tan '
                              'extensa como necesites.',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: Insets.lg),
                      Text(
                        'Etiquetas',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Se buscan en todas tus notas y proyectos, sin importar '
                        'mayúsculas ni acentos.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: Insets.sm),
                      CampoEtiqueta(
                        asignadasIds: _etiquetasIds,
                        onAsignar: (Etiqueta e) => setState(
                          () => _etiquetasIds = <String>{..._etiquetasIds, e.id},
                        ),
                        onQuitar: (Etiqueta e) => setState(
                          () => _etiquetasIds = <String>{..._etiquetasIds}..remove(e.id),
                        ),
                      ),
                      if (etiquetas.isNotEmpty) ...<Widget>[
                        const SizedBox(height: Insets.sm),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: etiquetas
                              .map(
                                (Etiqueta e) => EtiquetaChip(
                                  etiqueta: e,
                                  onRemove: () => setState(
                                    () => _etiquetasIds = <String>{..._etiquetasIds}
                                      ..remove(e.id),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(Insets.md),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _guardando ? null : _cancelar,
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: Insets.sm),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _guardando ? null : _guardar,
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: Text(_editando ? 'Guardar' : 'Crear nota'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelar() async {
    if (_hayCambios) {
      final bool descartar = await _pedirConfirmacion();
      if (!descartar || !mounted) {
        return;
      }
    }
    if (mounted && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
