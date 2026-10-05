import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../models/modelos.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scope.dart';
import '../widgets/widgets_comunes.dart';
import 'detalle_nota_screen.dart';
import 'home_shell.dart';
import 'notas_proyecto_screen.dart';

/// RF5. Gestión de etiquetas: alta, renombrado, borrado, búsqueda por nombre y
/// agrupación de notas de todos los proyectos.
///
/// La pantalla acepta `etiquetaInicial` para poder abrirse ya filtrada: desde el
/// detalle de una nota se pulsa una etiqueta y se llega aquí con esa selección
/// activa, que es la navegación que pide el requisito.
class EtiquetasScreen extends StatefulWidget {
  const EtiquetasScreen({this.etiquetaInicial, super.key});

  final String? etiquetaInicial;

  @override
  State<EtiquetasScreen> createState() => _EtiquetasScreenState();
}

class _EtiquetasScreenState extends State<EtiquetasScreen> {
  String _consulta = '';
  Set<String> _seleccionadas = <String>{};
  ModoAgrupacion _modo = ModoAgrupacion.todas;

  @override
  void initState() {
    super.initState();
    final String? inicial = widget.etiquetaInicial;
    if (inicial != null) {
      _seleccionadas = <String>{inicial};
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppStore store = AppScope.of(context);
    final List<Etiqueta> etiquetas = store.etiquetas
        .where((Etiqueta e) => e.coincideCon(_consulta))
        .toList()
      ..sort((Etiqueta a, Etiqueta b) {
        final int usoA = store.numeroNotasConEtiqueta(a.id);
        final int usoB = store.numeroNotasConEtiqueta(b.id);
        if (usoA != usoB) {
          return usoB.compareTo(usoA);
        }
        return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      });

    final List<Nota> notasAgrupadas = _notasAgrupadas(store);
    final bool agrupando = _seleccionadas.isNotEmpty;

    return Scaffold(
      appBar: BarraReNotes(
        subtitulo: agrupando
            ? '${_seleccionadas.length} etiqueta${_seleccionadas.length == 1 ? '' : 's'} seleccionada${_seleccionadas.length == 1 ? '' : 's'}'
            : 'Etiquetas',
        acciones: <Widget>[
          IconButton(
            tooltip: 'Nueva etiqueta',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _crear(context),
          ),
        ],
      ),
      floatingActionButton: agrupando
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _crear(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nueva etiqueta'),
            ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.md,
              Insets.sm,
              Insets.md,
              Insets.sm,
            ),
            child: CampoBusqueda(
              texto: _consulta,
              sugerencia: 'Buscar etiqueta',
              onChanged: (String valor) => setState(() => _consulta = valor),
            ),
          ),
          if (agrupando) _SelectorAgrupacion(
            modo: _modo,
            cantidad: _seleccionadas.length,
            onCambiarModo: (ModoAgrupacion m) => setState(() => _modo = m),
            onLimpiar: () => setState(() {
              _seleccionadas = <String>{};
              _modo = ModoAgrupacion.todas;
            }),
          ),
          Expanded(
            child: agrupando ? _resultados(notasAgrupadas) : _catalogo(etiquetas),
          ),
        ],
      ),
    );
  }

  Widget _catalogo(List<Etiqueta> etiquetas) {
    final AppStore store = AppScope.of(context);
    if (store.etiquetas.isEmpty) {
      return EstadoVacio(
        icono: Icons.sell_outlined,
        titulo: 'Aún no hay etiquetas',
        mensaje:
            'Crea una etiqueta y asígnala a tus notas para poder agruparlas y '
            'encontrarlas con facilidad.',
        accion: FilledButton.icon(
          onPressed: () => _crear(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Crear etiqueta'),
        ),
      );
    }
    if (etiquetas.isEmpty) {
      return const EstadoVacio(
        icono: Icons.search_off_rounded,
        titulo: 'Sin coincidencias',
        mensaje: 'Ninguna etiqueta coincide con tu búsqueda.',
      );
    }
    // ListView.builder: el catálogo crece con el uso y no interesa construirlo
    // entero de una vez.
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(Insets.md, 0, Insets.md, 96),
      itemCount: etiquetas.length,
      itemBuilder: (BuildContext context, int indice) {
        final Etiqueta etiqueta = etiquetas[indice];
        return _FilaEtiqueta(
          etiqueta: etiqueta,
          numNotas: store.numeroNotasConEtiqueta(etiqueta.id),
          onToggle: () => setState(
            () => _seleccionadas = <String>{
              ..._seleccionadas,
              etiqueta.id,
            },
          ),
          onRenombrar: () => _renombrar(context, etiqueta),
          onEliminar: () => _eliminar(context, etiqueta),
        );
      },
    );
  }

  Widget _resultados(List<Nota> notas) {
    if (notas.isEmpty) {
      return const EstadoVacio(
        icono: Icons.search_off_rounded,
        titulo: 'Ninguna nota coincide',
        mensaje:
            'No hay notas que cumplan la combinación de etiquetas seleccionada.',
      );
    }
    final AppStore store = AppScope.of(context);
    // ListView.separated: las notas muestran nombre de proyecto, así que la
    // separación con divisor ayuda a distinguirlas.
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Insets.md, 0, Insets.md, Insets.lg),
      itemCount: notas.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int indice) {
        final Nota nota = notas[indice];
        return TarjetaNota(
          nota: nota,
          nombreProyecto: store.proyectoPorId(nota.proyectoId)?.nombre ?? 'Sin proyecto',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetalleNotaScreen(notaId: nota.id),
            ),
          ),
        );
      },
    );
  }

  /// Notas de todos los proyectos que cumplen las etiquetas seleccionadas y el
  /// criterio de agrupación activo.
  List<Nota> _notasAgrupadas(AppStore store) {
    if (_seleccionadas.isEmpty) {
      return const <Nota>[];
    }
    final List<Nota> resultado = store.notas
        .where(
          (Nota n) => FiltroEtiquetas(
            seleccionadas: _seleccionadas,
            modo: _modo,
          ).satisface(n),
        )
        .toList()
      ..sort((Nota a, Nota b) => b.modificadoEn.compareTo(a.modificadoEn));
    return resultado;
  }

  Future<void> _crear(BuildContext context) async {
    final String? nombre = await _pedirNombre(context, titulo: 'Nueva etiqueta');
    if (nombre == null || !context.mounted) {
      return;
    }
    final AppStore store = AppScope.read(context);
    final Etiqueta? existente = store.etiquetaConNombre(nombre);
    if (existente != null) {
      avisar(context, 'La etiqueta «${existente.nombre}» ya existe.');
      return;
    }
    final Etiqueta nueva = store.crearSiNoExiste(nombre);
    setState(() => _seleccionadas = <String>{nueva.id});
    avisar(context, 'Etiqueta «${nueva.nombre}» creada');
  }

  Future<void> _renombrar(BuildContext context, Etiqueta etiqueta) async {
    final String? nombre = await _pedirNombre(
      context,
      titulo: 'Renombrar etiqueta',
      inicial: etiqueta.nombre,
    );
    if (nombre == null || !context.mounted) {
      return;
    }
    final AppStore store = AppScope.read(context);
    if (!store.renombrarEtiqueta(etiqueta.id, nombre)) {
      avisar(context, 'Ya existe una etiqueta con ese nombre.');
      return;
    }
    avisar(context, 'Etiqueta renombrada');
  }

  Future<void> _eliminar(BuildContext context, Etiqueta etiqueta) async {
    final AppStore store = AppScope.read(context);
    final int afectadas = store.numeroNotasConEtiqueta(etiqueta.id);
    final bool ok = await confirmar(
      context,
      titulo: 'Eliminar etiqueta',
      mensaje: afectadas == 0
          ? 'Se eliminará «${etiqueta.nombre}». No está en ninguna nota.'
          : 'Se eliminará «${etiqueta.nombre}» y se quitará de $afectadas '
              '${afectadas == 1 ? 'nota' : 'notas'}. Las notas no se borran.',
      confirmarTexto: 'Eliminar',
      icono: Icons.sell_outlined,
    );
    if (!ok || !context.mounted) {
      return;
    }
    AppScope.read(context).eliminarEtiqueta(etiqueta.id);
    setState(() => _seleccionadas = <String>{..._seleccionadas}..remove(etiqueta.id));
    avisar(context, 'Etiqueta eliminada');
  }

  /// Hoja de entrada para crear o renombrar. El nombre es obligatorio y la
  /// unicidad la comprueba el store, que distingue acentos y mayúsculas.
  Future<String?> _pedirNombre(
    BuildContext context, {
    required String titulo,
    String inicial = '',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) => _HojaNombreEtiqueta(titulo: titulo, inicial: inicial),
    );
  }
}

class _FilaEtiqueta extends StatelessWidget {
  const _FilaEtiqueta({
    required this.etiqueta,
    required this.numNotas,
    required this.onToggle,
    required this.onRenombrar,
    required this.onEliminar,
  });

  final Etiqueta etiqueta;
  final int numNotas;
  final VoidCallback onToggle;
  final VoidCallback onRenombrar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.sm),
      child: Card(
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(Corners.xl),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Insets.md,
              vertical: Insets.sm,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      EtiquetaChip(etiqueta: etiqueta),
                      const SizedBox(height: 6),
                      Text(
                        numNotas == 0
                            ? 'Sin notas'
                            : numNotas == 1
                                ? '1 nota'
                                : '$numNotas notas',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Opciones de la etiqueta',
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  onSelected: (String opcion) {
                    if (opcion == 'agrupar') {
                      onToggle();
                    } else if (opcion == 'renombrar') {
                      onRenombrar();
                    } else {
                      onEliminar();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'agrupar',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.checklist_rounded, size: 20),
                        title: Text('Agrupar por esta etiqueta'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'renombrar',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined, size: 20),
                        title: Text('Renombrar'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'eliminar',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: theme.colorScheme.error,
                        ),
                        title: Text(
                          'Eliminar',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right_rounded, color: theme.colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Control de agrupación «todas» / «al menos una» para la selección múltiple.
class _SelectorAgrupacion extends StatelessWidget {
  const _SelectorAgrupacion({
    required this.modo,
    required this.cantidad,
    required this.onCambiarModo,
    required this.onLimpiar,
  });

  final ModoAgrupacion modo;
  final int cantidad;
  final ValueChanged<ModoAgrupacion> onCambiarModo;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Insets.md),
      padding: const EdgeInsets.all(Insets.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Corners.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.checklist_rounded,
                size: 18,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: Text(
                  'Agrupando $cantidad etiqueta${cantidad == 1 ? '' : 's'}',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                ),
              ),
              TextButton(onPressed: onLimpiar, child: const Text('Limpiar')),
            ],
          ),
          const SizedBox(height: Insets.sm),
          SegmentedButton<ModoAgrupacion>(
            segments: const <ButtonSegment<ModoAgrupacion>>[
              ButtonSegment<ModoAgrupacion>(
                value: ModoAgrupacion.todas,
                label: Text('Todas'),
              ),
              ButtonSegment<ModoAgrupacion>(
                value: ModoAgrupacion.alguna,
                label: Text('Al menos una'),
              ),
            ],
            selected: <ModoAgrupacion>{modo},
            onSelectionChanged: (Set<ModoAgrupacion> seleccion) =>
                onCambiarModo(seleccion.first),
          ),
        ],
      ),
    );
  }
}

class _HojaNombreEtiqueta extends StatefulWidget {
  const _HojaNombreEtiqueta({required this.titulo, this.inicial = ''});

  final String titulo;
  final String inicial;

  @override
  State<_HojaNombreEtiqueta> createState() => _HojaNombreEtiquetaState();
}

class _HojaNombreEtiquetaState extends State<_HojaNombreEtiqueta> {
  late final TextEditingController _controlador =
      TextEditingController(text: widget.inicial);
  String? _error;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_controlador.text.trim().isEmpty) {
      setState(() => _error = 'El nombre de la etiqueta es obligatorio.');
      return;
    }
    Navigator.of(context).pop(_controlador.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: Insets.lg,
        right: Insets.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Insets.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.titulo, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: Insets.lg),
          TextField(
            controller: _controlador,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Nombre de la etiqueta',
              hintText: 'Ej.: Metodología',
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
            onSubmitted: (_) => _confirmar(),
          ),
          const SizedBox(height: Insets.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: FilledButton(
                  onPressed: _confirmar,
                  child: const Text('Aceptar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}