library;

const List<String> _mesesCortos = <String>[
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// `03 oct 2026`
String fechaCorta(DateTime fecha) {
  return '${_dosDigitos(fecha.day)} ${_mesesCortos[fecha.month - 1]} ${fecha.year}';
}

/// `03 oct 2026, 17:15`
String fechaConHora(DateTime fecha) {
  return '${fechaCorta(fecha)}, ${_dosDigitos(fecha.hour)}:${_dosDigitos(fecha.minute)}';
}

/// Estimación de tiempo de lectura a 200 palabras por minuto.
String tiempoLectura(String texto) {
  final int palabras = texto
      .trim()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .length;
  if (palabras == 0) {
    return 'Sin lectura';
  }
  final int minutos = (palabras / 200).ceil().clamp(1, 999);
  return minutos == 1 ? '1 min de lectura' : '$minutos min de lectura';
}

String _dosDigitos(int valor) => valor.toString().padLeft(2, '0');