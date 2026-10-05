/// Utilidades de texto compartidas por búsquedas, filtros y validación de
/// nombres de etiquetas.
///
/// El requisito del proyecto es que la comparación de etiquetas (y la búsqueda)
/// ignoren mayúsculas, minúsculas, acentos y espacios sobrantes. Centralizarlo
/// aquí evita duplicar la lógica en varias pantallas.
library;

/// Normaliza un texto para comparaciones: sin acentos, en minúsculas y sin
/// espacios al principio o al final.
///
/// «Metodología», «  metodologia » y «METODOLOGIA» producen la misma clave.
String normalizar(String texto) {
  final String sinEspacios = texto.trim();
  final StringBuffer buffer = StringBuffer();
  for (final int rune in sinEspacios.toLowerCase().runes) {
    final String letra = String.fromCharCode(rune);
    buffer.write(_sinAcento(letra));
  }
  return buffer.toString();
}

/// Reduce un carácter a su equivalente ASCII sin diacrítico.
///
/// Se recorre el rango latín extendido en lugar de usar un mapa gigante: los
/// datos de la app están en español y esta forma cubre áéíóúñü, mayúsculas,
/// vocales acentuadas y la diéresis (`ü` -> `u`), requisito habitual al
/// comparar etiquetas.
String _sinAcento(String letra) {
  const int inicio = 0xC0; // À
  const int fin = 0x17F; // ſ
  if (letra.length != 1) {
    return letra;
  }
  final int code = letra.codeUnitAt(0);
  if (code < inicio || code > fin) {
    return letra;
  }
  const List<String> sustituciones = <String>[
    'A', 'A', 'A', 'A', 'A', 'A', 'A', 'C', 'E', 'E', 'E', 'E', 'I', 'I', 'I',
    'I', // À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì
    'I', 'I', 'I', 'I', 'N', 'O', 'O', 'O', 'O', 'O', // Í Î Ï Ð Ñ Ò Ó Ô Õ
    'O', 'O', 'U', 'U', 'U', 'U', 'Y', 'Z', 'Z', 's', // Ö Ø Ù Ú Û Ü Ý Þ ß
    'a', 'a', 'a', 'a', 'a', 'a', 'c', 'e', 'e', 'e', 'e', 'i', 'i', 'i', 'i',
    'i', // à á â ã ä å æ ç è é ê ë ì
    'i', 'i', 'i', 'n', 'o', 'o', 'o', 'o', 'o', 'o', // í î ï ð ñ ò ó ô õ
    'o', 'o', 'u', 'u', 'u', 'u', 'y', 'z', 'z', 'y', // ö ø ù ú û ü ý þ ÿ
  ];
  final int indice = code - inicio;
  if (indice < sustituciones.length) {
    return sustituciones[indice];
  }
  return letra;
}

/// `true` cuando [texto] contiene [consulta] ignorando mayúsculas, minúsculas y
/// acentos. La búsqueda es por subcadena en cualquier posición.
bool contieneIgnorandoAcentos(String texto, String consulta) {
  if (consulta.isEmpty) {
    return true;
  }
  return normalizar(texto).contains(normalizar(consulta));
}

/// Devuelve un extracto legible de [texto] limitado a [maximo] caracteres,
/// cortando por palabra y añadiendo puntos suspensivos si hubo recorte.
String extractoTexto(String texto, {int maximo = 180}) {
  final String limpio = texto.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (limpio.length <= maximo) {
    return limpio;
  }
  final String recorte = limpio.substring(0, maximo);
  final int ultimoEspacio = recorte.lastIndexOf(' ');
  final String base = ultimoEspacio > maximo ~/ 2
      ? recorte.substring(0, ultimoEspacio)
      : recorte;
  return '$base…';
}

/// Recorta [texto] a [maximo] caracteres sin añadir puntos suspensivos.
String recortar(String texto, int maximo) {
  return texto.length <= maximo ? texto : texto.substring(0, maximo);
}