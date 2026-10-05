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

/// Reduce un carácter a su equivalente sin diacrítico.
///
/// Se resuelve por rangos del Suplemento Latino-1 (0xC0–0xFF) y con un mapa
/// para el handful de letras del Latin Extended-A que aparecen en nombres
/// propios. Los datos de la app están en español, así que esto cubre
/// áéíóúüñ y sus mayúsculas, que es lo que exige comparar etiquetas sin
/// acentos.
///
/// Puede devolver más de un carácter (`ß` -> `ss`), por eso quien llama
/// escribe el resultado en un [StringBuffer] en lugar de concatenar.
String _sinAcento(String letra) {
  if (letra.length != 1) {
    return letra;
  }
  final int code = letra.codeUnitAt(0);

  // Suplemento Latino-1, mayúsculas.
  if (code >= 0xC0 && code <= 0xC5) {
    return 'A'; // À Á Â Ã Ä Å
  }
  if (code == 0xC6) {
    return 'AE'; // Æ
  }
  if (code == 0xC7) {
    return 'C'; // Ç
  }
  if (code >= 0xC8 && code <= 0xCB) {
    return 'E'; // È É Ê Ë
  }
  if (code >= 0xCC && code <= 0xCF) {
    return 'I'; // Ì Í Î Ï
  }
  if (code == 0xD0) {
    return 'D'; // Ð
  }
  if (code == 0xD1) {
    return 'N'; // Ñ
  }
  if (code >= 0xD2 && code <= 0xD6) {
    return 'O'; // Ò Ó Ô Õ Ö
  }
  if (code == 0xD7) {
    return ''; // × (símbolo de multiplicación, no aporta texto)
  }
  if (code == 0xD8) {
    return 'O'; // Ø
  }
  if (code >= 0xD9 && code <= 0xDC) {
    return 'U'; // Ù Ú Û Ü
  }
  if (code == 0xDD) {
    return 'Y'; // Ý
  }
  if (code == 0xDE) {
    return 'TH'; // Þ
  }
  if (code == 0xDF) {
    return 'ss'; // ß
  }

  // Suplemento Latino-1, minúsculas.
  if (code >= 0xE0 && code <= 0xE5) {
    return 'a'; // à á â ã ä å
  }
  if (code == 0xE6) {
    return 'ae'; // æ
  }
  if (code == 0xE7) {
    return 'c'; // ç
  }
  if (code >= 0xE8 && code <= 0xEB) {
    return 'e'; // è é ê ë
  }
  if (code >= 0xEC && code <= 0xEF) {
    return 'i'; // ì í î ï
  }
  if (code == 0xF0) {
    return 'd'; // ð
  }
  if (code == 0xF1) {
    return 'n'; // ñ
  }
  if (code >= 0xF2 && code <= 0xF6) {
    return 'o'; // ò ó ô õ ö
  }
  if (code == 0xF7) {
    return ''; // ÷
  }
  if (code == 0xF8) {
    return 'o'; // ø
  }
  if (code >= 0xF9 && code <= 0xFC) {
    return 'u'; // ù ú û ü
  }
  if (code == 0xFD || code == 0xFF) {
    return 'y'; // ý ÿ
  }

  // Latin Extended-A: sólo letras que pueden aparecer en nombres propios.
  const Map<int, String> extendido = <int, String>{
    0x130: 'I', // İ
    0x131: 'i', // ı
    0x141: 'L', // Ł
    0x142: 'l', // ł
    0x152: 'OE', // Œ
    0x153: 'oe', // œ
    0x160: 'S', // Š
    0x161: 's', // š
    0x17D: 'Z', // Ž
    0x17E: 'z', // ž
    0x178: 'Y', // Ÿ
  };
  return extendido[code] ?? letra;
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