import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../models/modelos.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scope.dart';
import '../widgets/widgets_comunes.dart';
import 'detalle_nota_screen.dart';
import 'home_shell.dart';
import 'notas_proyecto_screen.dart';

/// RF6. Búsqueda global por título o contenido, con filtro opcional de proyecto
/// y de etiquetas.
///
/// Los resultados se actualizan en cada pulsación, sin botón de búsqueda: el
/// store ya filtra en memoria y la lista es corta.
class BuscarScreen extends StatefulWidget {
  const BuscarScreen({super.key});

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final TextEditingController _controlador = TextEditingController();
  String _consulta = '';
  String? _proyectoId;
  FiltroEtiquetas _filtro = const FiltroEtiquetas();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppStore store = AppScope.of(context);
    final List<Nota> resultados = store.buscar(
      consulta: _consulta,
      proyectoId: _proyectoId,
      filtro: _filtro,
    );
    final bool buscando = _consulta.trim().isNotEmpty || _filtro.activo || _proyectoId != null;

    return Scaffold(
      appBar: BarraReNotes(subtitulo: 'Buscar'),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.md,
              Insets.sm,
              Insets.md,
              Insets.sm,
            ),
            child: TextField(
              controller: _controlador,
              autofocus: false,
              onChanged: (String valor) => setState(() => _consulta = valor),
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Buscar por título o contenido',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _consulta.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() {
                          _controlador.clear();
                          _consulta = '';
                        }),
                      ),
              ),
            ),
          ),
          _Filtros(
            proyectoId: _proyectoId,
            filtro: _filtro,
            onProyecto: (String? id) => setState(() => _proyectoId = id),
            onAlternarEtiqueta: (Etiqueta e) =>
                setState(() => _filtro = _filtro.alternar(e.id)),
            onLimpiar: () => setState(() {
              _proyectoId = null;
              _filtro = _filtro.limpiar();
            }),
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
                  buscando
                      ? '${resultados.length} resultado${resultados.length == 1 ? '' : 's'}'
                      : 'Busca en todos tus proyectos',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const Spacer(),
                if (buscando)
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _controlador.clear();
                      _consulta = '';
                      _proyectoId = null;
                      _filtro = _filtro.limpiar();
                    }),
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                    label: const Text('Limpiar filtros'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: resultados.isEmpty
                ? EstadoVacio(
                    icono: buscando ? Icons.search_off_rounded : Icons.search_rounded,
                    titulo: buscando ? 'Sin coincidencias' : 'Búsqueda global',
                    mensaje: buscando
                        ? 'No hay notas que coincidan con la búsqueda o los '
                            'filtros aplicados.'
                        : 'Escribe en el campo superior para encontrar notas por '
                            'su título o su contenido, en cualquier proyecto.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      Insets.md,
                      0,
                      Insets.md,
                      Insets.lg,
                    ),
                    itemCount: resultados.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (BuildContext context, int indice) {
                      final Nota nota = resultados[indice];
                      return TarjetaNota(
                        nota: nota,
                        nombreProyecto:
                            store.proyectoPorId(nota.proyectoId)?.nombre ?? 'Sin proyecto',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DetalleNotaScreen(notaId: nota.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Fila de filtros: proyecto desplegable y etiquetas horizontales.
class _Filtros extends StatelessWidget {
  const _Filtros({
    required this.proyectoId,
    required this.filtro,
    required this.onProyecto,
    required this.onAlternarEtiqueta,
    required this.onLimpiar,
  });

  final String? proyectoId;
  final FiltroEtiquetas filtro;
  final ValueChanged<String?> onProyecto;
  final ValueChanged<Etiqueta> onAlternarEtiqueta;
  final VoidCallback onLimpiar;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppStore store = AppScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Insets.md),
            children: <Widget>[
              FilterChip(
                label: const Text('Todos los proyectos'),
                selected: proyectoId == null,
                onSelected: (_) => onProyecto(null),
              ),
              const SizedBox(width: Insets.sm),
              for (final Proyecto p in store.proyectos) ...<Widget>[
                FilterChip(
                  label: Text(p.nombre),
                  selected: proyectoId == p.id,
                  onSelected: (bool activo) => onProyecto(activo ? p.id : null),
                ),
                const SizedBox(width: Insets.sm),
              ],
            ],
          ),
        ),
        if (store.etiquetas.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Insets.md),
              itemCount: store.etiquetas.length + (filtro.activo ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (BuildContext context, int indice) {
                if (indice == store.etiquetas.length) {
                  return ActionChip(
                    avatar: const Icon(Icons.close_rounded, size: 14),
                    label: const Text('Quitar'),
                    onPressed: onLimpiar,
                    labelStyle: theme.textTheme.labelMedium,
                  );
                }
                final Etiqueta etiqueta = store.etiquetas[indice];
                return EtiquetaChip(
                  etiqueta: etiqueta,
                  seleccionada: filtro.contiene(etiqueta.id),
                  onTap: () => onAlternarEtiqueta(etiqueta),
                );
              },
            ),
          ),
        if (filtro.activo)
          Padding(
            padding: const EdgeInsets.fromLTRB(Insets.md, 0, Insets.md, Insets.sm),
            child: Row(
              children: <Widget>[
                Icon(Icons.info_outline_rounded,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    filtro.modo == ModoAgrupacion.todas
                        ? 'Las notas deben tener todas las etiquetas seleccionadas.'
                        : 'Las notas deben tener al menos una de las etiquetas '
                            'seleccionadas.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}