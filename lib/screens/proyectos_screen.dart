import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../models/modelos.dart';
import '../theme/app_theme.dart';
import '../utils/fechas.dart';
import '../widgets/app_scope.dart';
import '../widgets/widgets_comunes.dart';
import 'home_shell.dart';
import 'notas_proyecto_screen.dart';

/// RF1. Listado de proyectos con creación, edición y eliminación.
///
/// La lista usa `ListView.builder` porque el número de proyectos crece con el
/// uso y no conviene construir todos los elementos de golpe.
class ProyectosScreen extends StatefulWidget {
  const ProyectosScreen({super.key});

  @override
  State<ProyectosScreen> createState() => _ProyectosScreenState();
}

class _ProyectosScreenState extends State<ProyectosScreen> {
  String _consulta = '';

  @override
  Widget build(BuildContext context) {
    final AppStore store = AppScope.of(context);
    final List<Proyecto> proyectos = store.proyectos
        .where((Proyecto p) => p.coincideCon(_consulta))
        .toList()
      ..sort((Proyecto a, Proyecto b) =>
          b.modificadoEn.compareTo(a.modificadoEn));

    return Scaffold(
      appBar: const BarraReNotes(subtitulo: 'Proyectos'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo proyecto'),
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
              sugerencia: 'Buscar proyecto',
              onChanged: (String valor) => setState(() => _consulta = valor),
            ),
          ),
          Expanded(
            child: store.proyectos.isEmpty
                ? EstadoVacio(
                    icono: Icons.folder_open_rounded,
                    titulo: 'Aún no hay proyectos',
                    mensaje:
                        'Crea tu primer proyecto para empezar a organizar tus '
                        'notas de investigación.',
                    accion: FilledButton.icon(
                      onPressed: () => _abrirEditor(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Crear proyecto'),
                    ),
                  )
                : proyectos.isEmpty
                    ? const EstadoVacio(
                        icono: Icons.search_off_rounded,
                        titulo: 'Sin coincidencias',
                        mensaje:
                            'Ningún proyecto coincide con tu búsqueda.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          Insets.md,
                          Insets.sm,
                          Insets.md,
                          96,
                        ),
                        itemCount: proyectos.length,
                        itemBuilder: (BuildContext context, int indice) {
                          final Proyecto proyecto = proyectos[indice];
                          return _TarjetaProyecto(
                            proyecto: proyecto,
                            numNotas: store.numeroNotasDeProyecto(proyecto.id),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    NotasProyectoScreen(proyectoId: proyecto.id),
                              ),
                            ),
                            onEditar: () => _abrirEditor(
                              context,
                              existente: proyecto,
                            ),
                            onEliminar: () => _eliminar(context, proyecto),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirEditor(
    BuildContext context, {
    Proyecto? existente,
  }) async {
    final Proyecto? resultado = await showModalBottomSheet<Proyecto>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HojaProyecto(existente: existente),
    );
    if (resultado == null || !context.mounted) {
      return;
    }
    final AppStore store = AppScope.read(context);
    if (existente == null) {
      final String? id = store.crearProyecto(
        nombre: resultado.nombre,
        descripcion: resultado.descripcion,
      );
      if (id != null) {
        avisar(context, 'Proyecto «${resultado.nombre}» creado');
      }
    } else {
      store.actualizarProyecto(
        id: existente.id,
        nombre: resultado.nombre,
        descripcion: resultado.descripcion,
      );
      avisar(context, 'Proyecto actualizado');
    }
  }

  Future<void> _eliminar(BuildContext context, Proyecto proyecto) async {
    final int numNotas = AppScope.read(context).numeroNotasDeProyecto(proyecto.id);
    final bool ok = await confirmar(
      context,
      titulo: 'Eliminar proyecto',
      mensaje: numNotas == 0
          ? 'Se eliminará «${proyecto.nombre}». Esta acción no se puede deshacer.'
          : 'Se eliminará «${proyecto.nombre}» y sus $numNotas '
              '${numNotas == 1 ? 'nota' : 'notas'}. '
              'Las etiquetas se conservarán.',
      confirmarTexto: 'Eliminar',
    );
    if (!ok || !context.mounted) {
      return;
    }
    AppScope.read(context).eliminarProyecto(proyecto.id);
    avisar(context, 'Proyecto eliminado');
  }
}

class _TarjetaProyecto extends StatelessWidget {
  const _TarjetaProyecto({
    required this.proyecto,
    required this.numNotas,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  final Proyecto proyecto;
  final int numNotas;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Insets.sm),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Corners.xl),
          child: Padding(
            padding: const EdgeInsets.all(Insets.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(Corners.md),
                      ),
                      child: Icon(
                        Icons.folder_rounded,
                        size: 22,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: Insets.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            proyecto.nombre,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fechaCorta(proyecto.modificadoEn),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    _MenuProyecto(
                      onEditar: onEditar,
                      onEliminar: onEliminar,
                    ),
                  ],
                ),
                if (proyecto.descripcion.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Insets.sm),
                  Text(
                    proyecto.descripcion,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: Insets.sm),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.description_outlined,
                      size: 15,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      numNotas == 1 ? '1 nota' : '$numNotas notas',
                      style: theme.textTheme.labelMedium,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Abrir',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuProyecto extends StatelessWidget {
  const _MenuProyecto({required this.onEditar, required this.onEliminar});

  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Opciones del proyecto',
      icon: const Icon(Icons.more_vert_rounded, size: 20),
      onSelected: (String opcion) {
        if (opcion == 'editar') {
          onEditar();
        } else {
          onEliminar();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'editar',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined, size: 20),
            title: Text('Editar'),
          ),
        ),
        PopupMenuItem<String>(
          value: 'eliminar',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Eliminar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}

/// Hoja inferior para crear o editar un proyecto.
///
/// El nombre es obligatorio (RF1). El único error posible se muestra bajo el
/// campo en vez de en un diálogo para que el mensaje quede junto al campo que lo
/// provoca.
class _HojaProyecto extends StatefulWidget {
  const _HojaProyecto({this.existente});

  final Proyecto? existente;

  @override
  State<_HojaProyecto> createState() => _HojaProyectoState();
}

class _HojaProyectoState extends State<_HojaProyecto> {
  late final TextEditingController _nombre =
      TextEditingController(text: widget.existente?.nombre ?? '');
  late final TextEditingController _descripcion =
      TextEditingController(text: widget.existente?.descripcion ?? '');
  String? _error;

  bool get _editando => widget.existente != null;

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_nombre.text.trim().isEmpty) {
      setState(() => _error = 'El nombre del proyecto es obligatorio.');
      return;
    }
    Navigator.of(context).pop(
      Proyecto(
        id: widget.existente?.id ?? '',
        nombre: _nombre.text,
        descripcion: _descripcion.text,
        creadoEn: widget.existente?.creadoEn ?? DateTime.now(),
        modificadoEn: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: Insets.lg,
        right: Insets.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Insets.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _editando ? 'Editar proyecto' : 'Nuevo proyecto',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: Insets.lg),
            TextField(
              controller: _nombre,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ej.: Psicología Cognitiva',
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
              onSubmitted: (_) => _guardar(),
            ),
            const SizedBox(height: Insets.md),
            TextField(
              controller: _descripcion,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción breve',
                hintText: 'Opcional: de qué trata el proyecto',
                alignLabelWithHint: true,
              ),
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
                    onPressed: _guardar,
                    child: Text(_editando ? 'Guardar' : 'Crear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}