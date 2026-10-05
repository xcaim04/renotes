import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../models/modelos.dart';
import '../theme/app_theme.dart';
import '../utils/fechas.dart';
import '../widgets/app_scope.dart';
import '../widgets/widgets_comunes.dart';
import 'editor_nota_screen.dart';
import 'etiquetas_screen.dart';

/// RF4. Detalle de una nota: metadatos, cuerpo desplazable y etiquetas navegables.
class DetalleNotaScreen extends StatefulWidget {
  const DetalleNotaScreen({required this.notaId, super.key});

  final String notaId;

  @override
  State<DetalleNotaScreen> createState() => _DetalleNotaScreenState();
}

class _DetalleNotaScreenState extends State<DetalleNotaScreen> {
  /// Ids de las notas relacionadas que el usuario ya abrió desde aquí. Evita
  /// apilar pantallas idénticas al saltar entre notas con una etiqueta común.
  final Set<String> _visitadas = <String>{};

  @override
  void initState() {
    super.initState();
    _visitadas.add(widget.notaId);
  }

  @override
  Widget build(BuildContext context) {
    final AppStore store = AppScope.of(context);
    final Nota? nota = store.notaPorId(widget.notaId);

    if (nota == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EstadoVacio(
          icono: Icons.note_alt_outlined,
          titulo: 'Nota no disponible',
          mensaje: 'La nota se ha eliminado.',
        ),
      );
    }

    final Proyecto? proyecto = store.proyectoPorId(nota.proyectoId);
    final List<Etiqueta> etiquetas = nota.etiquetasIds
        .map(store.etiquetaPorId)
        .whereType<Etiqueta>()
        .toList()
      ..sort((Etiqueta a, Etiqueta b) =>
          a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Editar nota',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EditorNotaScreen(
                    proyectoId: nota.proyectoId,
                    notaId: nota.id,
                  ),
                ),
              );
              if (mounted) {
                setState(() {});
              }
            },
          ),
          IconButton(
            tooltip: 'Eliminar nota',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _eliminar(context, nota),
          ),
          const SizedBox(width: Insets.sm),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // El cuerpo de una nota puede ser muy largo: todo el detalle vive en
          // un único desplazable para que no aparezcan barras anidadas.
          padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(nota.titulo, style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: Insets.md),
              _Metadatos(nota: nota, proyecto: proyecto),
              const SizedBox(height: Insets.lg),
              if (etiquetas.isNotEmpty) ...<Widget>[
                Text(
                  'ETIQUETAS',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: Insets.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: etiquetas
                      .map(
                        (Etiqueta e) => EtiquetaChip(
                          etiqueta: e,
                          // Al pulsar una etiqueta se abre la pantalla de
                          // etiquetas filtrada por ella.
                          onTap: () => _abrirEtiqueta(context, e),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: Insets.lg),
              ],
              const Divider(),
              const SizedBox(height: Insets.md),
              Text(
                nota.descripcion.trim().isEmpty
                    ? 'Esta nota todavía no tiene descripción.'
                    : nota.descripcion.trim(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _NotasRelacionadas(
        nota: nota,
        visitadas: _visitadas,
        onAbrir: (String notaId) => _abrirNota(context, notaId),
      ),
    );
  }

  Future<void> _abrirEtiqueta(BuildContext context, Etiqueta etiqueta) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EtiquetasScreen(etiquetaInicial: etiqueta.id),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _abrirNota(BuildContext context, String notaId) async {
    setState(() => _visitadas.add(notaId));
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetalleNotaScreen(notaId: notaId)),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _eliminar(BuildContext context, Nota nota) async {
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
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _Metadatos extends StatelessWidget {
  const _Metadatos({required this.nota, required this.proyecto});

  final Nota nota;
  final Proyecto? proyecto;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (proyecto != null) ...<Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.folder_rounded,
                size: 15,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  proyecto!.nombre,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: theme.colorScheme.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.sm),
        ],
        Text(
          'Creada el ${fechaConHora(nota.creadoEn)}',
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: 2),
        Text(
          'Modificada el ${fechaConHora(nota.modificadoEn)}',
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: 2),
        Text(tiempoLectura(nota.descripcion), style: theme.textTheme.labelSmall),
        const Divider(height: Insets.lg),
      ],
    );
  }
}

/// Notas que comparten alguna etiqueta con la nota abierta.
///
/// Se ofrece como barra inferior porque es un atajo, no el contenido principal de
/// la pantalla: cumple el requisito de que las etiquetas naveguen sin obligar a
/// volver a la lista.
class _NotasRelacionadas extends StatelessWidget {
  const _NotasRelacionadas({
    required this.nota,
    required this.visitadas,
    required this.onAbrir,
  });

  final Nota nota;
  final Set<String> visitadas;
  final ValueChanged<String> onAbrir;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppStore store = AppScope.of(context);

    if (nota.etiquetasIds.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<Nota> relacionadas = store.notas
        .where((Nota n) =>
            n.id != nota.id &&
            n.etiquetasIds.any(nota.etiquetasIds.contains))
        .where((Nota n) => !visitadas.contains(n.id))
        .take(6)
        .toList()
      ..sort((Nota a, Nota b) => b.modificadoEn.compareTo(a.modificadoEn));

    if (relacionadas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      color: theme.colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: Insets.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Insets.md),
                child: Text('NOTAS RELACIONADAS', style: theme.textTheme.labelSmall),
              ),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Insets.md),
                  itemCount: relacionadas.length,
                  separatorBuilder: (_, _) => const SizedBox(width: Insets.sm),
                  itemBuilder: (BuildContext context, int i) {
                    final Nota n = relacionadas[i];
                    return SizedBox(
                      width: 190,
                      child: Material(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(Corners.lg),
                        child: InkWell(
                          onTap: () => onAbrir(n.id),
                          borderRadius: BorderRadius.circular(Corners.lg),
                          child: Padding(
                            padding: const EdgeInsets.all(Insets.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  n.titulo,
                                  style: theme.textTheme.titleSmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  store.proyectoPorId(n.proyectoId)?.nombre ?? '',
                                  style: theme.textTheme.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}