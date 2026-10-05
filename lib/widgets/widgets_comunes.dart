import 'package:flutter/material.dart';

import '../models/modelos.dart';
import '../theme/app_theme.dart';

/// Etiqueta visual de una [Etiqueta].
///
/// El color se deriva del id mediante [TagPalette.of], así que una etiqueta
/// conserva el mismo tono entre el modo claro y el oscuro y entre pantallas.
class EtiquetaChip extends StatelessWidget {
  const EtiquetaChip({
    required this.etiqueta,
    this.seleccionada = false,
    this.onTap,
    this.onRemove,
    this.compacta = false,
    super.key,
  });

  final Etiqueta etiqueta;
  final bool seleccionada;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Brightness brillo = theme.brightness;
    final TagPalette paleta = TagPalette.of(etiqueta.id, brillo);

    final Color fondo = seleccionada ? paleta.dot : paleta.container;
    final Color tinta = seleccionada ? _contrasteSobre(paleta.dot) : paleta.ink;
    final TextStyle estilo = (compacta
            ? theme.textTheme.labelSmall
            : theme.textTheme.labelMedium)!
        .copyWith(
      color: tinta,
      fontWeight: seleccionada ? FontWeight.w700 : FontWeight.w500,
    );

    final Widget contenido = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (!compacta) ...<Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: tinta, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        Text(etiqueta.nombre, style: estilo),
      ],
    );

    return Material(
      color: fondo,
      borderRadius: BorderRadius.circular(Corners.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Corners.sm),
        child: Padding(
          padding: EdgeInsets.only(
            left: compacta ? 8 : 10,
            right: onRemove == null ? (compacta ? 8 : 10) : 2,
            top: compacta ? 4 : 6,
            bottom: compacta ? 4 : 6,
          ),
          // La «x» es un botón propio y no el mismo gesto que el resto del chip:
          // quitar una etiqueta no debe equivaler a seleccionarla.
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              contenido,
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                  tooltip: 'Quitar ${etiqueta.nombre}',
                  icon: Icon(Icons.close_rounded, size: 14, color: tinta),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Elige blanco o casi negro según la luminancia del fondo para no perder
  /// contraste cuando la etiqueta está seleccionada.
  static Color _contrasteSobre(Color fondo) {
    return fondo.computeLuminance() > 0.5 ? const Color(0xFF1A1B1E) : Colors.white;
  }
}

/// Fila de etiquetas con desplazamiento horizontal.
///
/// Un `Wrap` en una columna habría ocupado toda la altura del contenido, así que
/// las listas largas de etiquetas usan una fila desplazable: mantiene la altura
/// de la tarjeta estable y evita desbordamientos con muchas etiquetas.
class FilaEtiquetas extends StatelessWidget {
  const FilaEtiquetas({
    required this.etiquetas,
    this.onTap,
    this.onRemove,
    this.compacta = false,
    this.altura = 32,
    super.key,
  });

  final List<Etiqueta> etiquetas;
  final void Function(Etiqueta etiqueta)? onTap;
  final void Function(Etiqueta etiqueta)? onRemove;
  final bool compacta;
  final double altura;

  @override
  Widget build(BuildContext context) {
    if (etiquetas.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<Widget> chips = etiquetas
        .map(
          (Etiqueta e) => EtiquetaChip(
            etiqueta: e,
            onTap: onTap == null ? null : () => onTap!(e),
            onRemove: onRemove == null ? null : () => onRemove!(e),
            compacta: compacta,
          ),
        )
        .toList();

    return SizedBox(
      height: altura,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, int i) => chips[i],
      ),
    );
  }
}

/// Indicador «sin resultados» reutilizado por las cuatro pantallas con listas.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
    super.key,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Insets.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                size: 34,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: Insets.md),
            Text(
              titulo,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Insets.sm),
            Text(
              mensaje,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (accion != null) ...<Widget>[
              const SizedBox(height: Insets.lg),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Campo de búsqueda con botón para limpiar.
///
/// El controlador vive en el [State] para no perder el cursor al reconstruir,
/// y se sincroniza con [texto] cuando la pantalla padre cambia el valor desde
/// fuera (por ejemplo, al pulsar «limpiar» o al aplicar un filtro).
class CampoBusqueda extends StatefulWidget {
  const CampoBusqueda({
    required this.texto,
    required this.onChanged,
    this.sugerencia = 'Buscar',
    this.autofocus = false,
    super.key,
  });

  final String texto;
  final ValueChanged<String> onChanged;
  final String sugerencia;
  final bool autofocus;

  @override
  State<CampoBusqueda> createState() => _CampoBusquedaState();
}

class _CampoBusquedaState extends State<CampoBusqueda> {
  late final TextEditingController _controlador =
      TextEditingController(text: widget.texto);

  @override
  void didUpdateWidget(CampoBusqueda oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.texto != _controlador.text) {
      _controlador.value = TextEditingValue(
        text: widget.texto,
        selection: TextSelection.collapsed(offset: widget.texto.length),
      );
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _limpiar() {
    _controlador.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controlador,
      onChanged: widget.onChanged,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: widget.sugerencia,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: widget.texto.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar búsqueda',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: _limpiar,
              ),
      ),
    );
  }
}

/// Diálogo de confirmación para acciones destructivas.
///
/// Envuelve el diálogo del sistema para que todas las confirmaciones de la app
/// compartan estructura, colores y tamaño de botón.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensaje,
  required String confirmarTexto,
  String cancelarTexto = 'Cancelar',
  IconData icono = Icons.warning_amber_rounded,
}) async {
  final bool? resultado = await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) {
      final ThemeData theme = Theme.of(ctx);
      return AlertDialog(
        icon: Icon(icono, color: theme.colorScheme.error),
        title: Text(titulo),
        content: Text(mensaje),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelarTexto),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmarTexto),
          ),
        ],
      );
    },
  );
  return resultado ?? false;
}

/// Encabezado de sección con título, descripción opcional y acción a la derecha.
class EncabezadoSeccion extends StatelessWidget {
  const EncabezadoSeccion({
    required this.titulo,
    this.subtitulo,
    this.accion,
    super.key,
  });

  final String titulo;
  final String? subtitulo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(titulo, style: theme.textTheme.titleMedium),
              if (subtitulo != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  subtitulo!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        ?accion,
      ],
    );
  }
}

/// Muestra un mensaje breve en la pantalla actual.
void avisar(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensaje)));
}