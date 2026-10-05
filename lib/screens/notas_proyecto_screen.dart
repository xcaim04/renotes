import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../models/modelos.dart';
import '../theme/app_theme.dart';
import '../utils/fechas.dart';
import '../widgets/app_scope.dart';
import '../widgets/widgets_comunes.dart';
import 'detalle_nota_screen.dart';
import 'editor_nota_screen.dart';

/// RF2. Notas de un proyecto: búsqueda interna y filtro por etiquetas.
///
/// El filtro ofrece solo las etiquetas que aparecen en las notas de este
/// proyecto: ofrecer una etiqueta sin notas produciría un filtro que siempre
/// devuelve una lista vacía y confundiría a quien usa la pantalla.
class NotasProyectoScreen extends StatefulWidget {
  const NotasProyectoScreen({required this.proyectoId, super.key});

  final String proyectoId;

  @override
  State<NotasProyectoScreen> createState() => _NotasProyectoScreenState();
}

class _NotasProyectoScreenState extends State<NotasProyectoScreen> {
  String _consulta = '';
  FiltroEtiquetas _filtro = const FiltroEtiquetas();

  @override
  Widget build(BuildContext context) {
    final AppStore store = AppScope.of(context);
    final Proyecto? proyecto = store.proyectoPorId(widget.proyectoId);

    // El proyecto puede desaparecer mientras la pantalla está abierta si se
    // borra desde otra pestaña; en ese caso no hay nada que mostrar.
    if (proyecto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notas')),
        body: const EstadoVacio(
          icono: Icons.folder_off_rounded,
          titulo: 'Proyecto no disponible',
          mensaje: 'El proyecto se ha eliminado.',
        ),
      );
    }

    final List<Nota> notas = store.notasDeProyectoFiltradas(
      proyectoId: proyecto.id,
      consulta: _consulta,
      filtro: _filtro,
    );
    final List<Etiqueta> etiquetasDisponibles = store.etiquetasDeProyecto(proyecto.id);
    final int total = store.numeroNotasDeProyecto(proyecto.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(proyecto.nombre),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Eliminar proyecto',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _eliminarProyecto(context, proyecto),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<String>(
            builder: (_) => EditorNotaScreen(proyectoId: proyecto.id),
          ),
        ),
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Nueva nota'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.md,
              Insets.md,
              Insets.md,
              Insets.sm,
            ),
            child: CampoBusqueda(
              texto: _consulta,
              sugerencia: 'Buscar en este proyecto',
              onChanged: (String valor) => setState(() => _consulta = valor),
            ),
          ),
          if (etiquetasDisponibles.isNotEmpty)
            _FilaFiltroEtiquetas(
              etiquetas: etiquetasDisponibles,
              filtro: _filtro,
              onAlternar: (Etiqueta e) => setState(
                () => _filtro = _filtro.alternar(e.id),
              ),
              onLimpiar: () => setState(() => _filtro = _filtro.limpiar()),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.md,
              Insets.sm,
              Insets.md,
              Insets.sm,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  notas.length == total
                      ? '$total ${total == 1 ? 'nota' : 'notas'}'
                      : '${notas.length} de $total notas',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                if (_consulta.isNotEmpty || _filtro.activo)
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _consulta = '';
                      _filtro = _filtro.limpiar();
                    }),
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                    label: const Text('Limpiar filtros'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: total == 0
                ? EstadoVacio(
                    icono: Icons.note_add_outlined,
                    titulo: 'Proyecto sin notas',
                    mensaje:
                        'Añade la primera nota de «${proyecto.nombre}» para '
                        'empezar a documentarlo.',
                    accion: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<String>(
                          builder: (_) => EditorNotaScreen(proyectoId: proyecto.id),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Crear nota'),
                    ),
                  )
                : notas.isEmpty
                    ? const EstadoVacio(
                        icono: Icons.search_off_rounded,
                        titulo: 'Sin coincidencias',
                        mensaje:
                            'Ninguna nota de este proyecto coincide con la '
                            'búsqueda o el filtro aplicado.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          Insets.md,
                          0,
                          Insets.md,
                          96,
                        ),
                        itemCount: notas.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (BuildContext context, int indice) {
                          final Nota nota = notas[indice];
                          return TarjetaNota(
                            nota: nota,
                            nombreProyecto: proyecto.nombre,
                            mostrarProyecto: false,
                            onTap: () => _abrirDetalle(context, nota.id),
                            onEliminar: () => _eliminarNota(context, nota),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirDetalle(BuildContext context, String notaId) async {
    final AppStore store = AppScope.read(context);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetalleNotaScreen(notaId: notaId),
      ),
    );
    // La nota pudo editarse o borrarse desde el detalle.
    if (!mounted) {
      return;
    }
    setState(() {});
    // Si el proyecto ya no existe, no hay nada que mostrar: se sale de la
    // pantalla en lugar de mostrar un listado vacío sin explicación.
    if (context.mounted && store.proyectoPorId(widget.proyectoId) == null) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _eliminarNota(BuildContext context, Nota nota) async {
    final bool ok = await confirmar(
      context,
      titulo: 'Eliminar nota',
      mensaje: 'Se eliminará «${nota.titulo}». Esta acción no se puede deshacer.',
      confirmarTexto: 'Eliminar',
      icono: Icons.delete_outline_rounded,
    );
    if (!ok || !context.mounted) {
      return;
    }
    AppScope.read(context).eliminarNota(nota.id);
    avisar(context, 'Nota eliminada');
  }

  Future<void> _eliminarProyecto(BuildContext context, Proyecto proyecto) async {
    final int numNotas = AppScope.read(context).numeroNotasDeProyecto(proyecto.id);
    final bool ok = await confirmar(
      context,
      titulo: 'Eliminar proyecto',
      mensaje: numNotas == 0
          ? 'Se eliminará «${proyecto.nombre}».'
          : 'Se eliminará «${proyecto.nombre}» y sus $numNotas '
              '${numNotas == 1 ? 'nota' : 'notas'}.',
      confirmarTexto: 'Eliminar',
    );
    if (!ok || !context.mounted) {
      return;
    }
    AppScope.read(context).eliminarProyecto(proyecto.id);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

/// Fila desplazable de etiquetas con función de filtro.
class _FilaFiltroEtiquetas extends StatelessWidget {
  const _FilaFiltroEtiquetas({
    required this.etiquetas,
    required this.filtro,
    required this.onAlternar,
    required this.onLimpiar,
  });

  final List<Etiqueta> etiquetas;
  final FiltroEtiquetas filtro;
  final ValueChanged<Etiqueta> onAlternar;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<Widget> chips = <Widget>[
      for (final Etiqueta etiqueta in etiquetas)
        EtiquetaChip(
          etiqueta: etiqueta,
          seleccionada: filtro.contiene(etiqueta.id),
          onTap: () => onAlternar(etiqueta),
        ),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Insets.md),
        itemCount: chips.length + (filtro.activo ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (BuildContext context, int indice) {
          if (indice < chips.length) {
            return chips[indice];
          }
          return ActionChip(
            avatar: const Icon(Icons.close_rounded, size: 14),
            label: const Text('Quitar'),
            onPressed: onLimpiar,
            labelStyle: theme.textTheme.labelMedium,
          );
        },
      ),
    );
  }
}

/// Tarjeta de nota reutilizada en la lista de proyecto, en la pantalla de
/// etiquetas y en los resultados de búsqueda.
class TarjetaNota extends StatelessWidget {
  const TarjetaNota({
    required this.nota,
    required this.onTap,
    required this.nombreProyecto,
    this.mostrarProyecto = true,
    this.onEliminar,
    super.key,
  });

  final Nota nota;
  final VoidCallback onTap;
  final String nombreProyecto;
  final bool mostrarProyecto;
  final VoidCallback? onEliminar;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppStore store = AppScope.of(context);
    final List<Etiqueta> etiquetas = nota.etiquetasIds
        .map(store.etiquetaPorId)
        .whereType<Etiqueta>()
        .toList()
      ..sort((Etiqueta a, Etiqueta b) =>
          a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Insets.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              nota.titulo,
              style: theme.textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(nota.extracto(), style: theme.textTheme.bodyMedium),
            const SizedBox(height: Insets.sm),
            if (mostrarProyecto) ...<Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.folder_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      nombreProyecto,
                      style: theme.textTheme.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Insets.sm),
            ],
            Row(
              children: <Widget>[
                Expanded(
                  child: etiquetas.isEmpty
                      ? Text(
                          'Sin etiquetas',
                          style: theme.textTheme.labelSmall,
                        )
                      : FilaEtiquetas(
                          etiquetas: etiquetas,
                          compacta: true,
                          altura: 24,
                        ),
                ),
                const SizedBox(width: Insets.sm),
                Text(
                  fechaCorta(nota.modificadoEn),
                  style: theme.textTheme.labelSmall,
                ),
                if (onEliminar != null)
                  PopupMenuButton<String>(
                    tooltip: 'Opciones de la nota',
                    icon: Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (String opcion) {
                      if (opcion == 'eliminar') {
                        onEliminar!();
                      }
                    },
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}