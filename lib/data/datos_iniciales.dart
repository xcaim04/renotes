import '../models/modelos.dart';

/// Datos iniciales de la app.
///
/// El enunciado fija un volumen mínimo para poder comprobar las pantallas con
/// contenido realista: 3 proyectos, 15 notas, 8 etiquetas, al menos 3 etiquetas
/// usadas en notas de proyectos distintos, al menos 5 notas con descripción
/// larga, al menos una nota sin etiquetas y al menos una etiqueta sin notas.
///
/// Todas las fechas se derivan de [_ahora] para que el conjunto sea estable y
/// las fechas de modificación siempre parezcan recientes al abrir la app.
class DatosIniciales {
  const DatosIniciales._();

  static const String proyectoPsicologia = 'p_psicologia';
  static const String proyectoFilosofia = 'p_filosofia';
  static const String proyectoHistoria = 'p_historia';

  static const String etMetodologia = 'e_metodologia';
  static const String etHistoriaMental = 'e_historia_mental';
  static const String etEtica = 'e_etica';
  static const String etFilosofia = 'e_filosofia';
  static const String etTesis = 'e_tesis';
  static const String etContexto = 'e_contexto';
  static const String etRevision = 'e_revision';
  static const String etPendiente = 'e_pendiente';
  static const String etBibliografia = 'e_bibliografia';

  static List<Proyecto> proyectos(DateTime ahora) {
    return <Proyecto>[
      Proyecto(
        id: proyectoPsicologia,
        nombre: 'Psicología Cognitiva',
        descripcion:
            'Atención, memoria de trabajo y sesgos cognitivos en tareas académicas.',
        creadoEn: ahora.subtract(const Duration(days: 42)),
        modificadoEn: ahora.subtract(const Duration(hours: 6)),
      ),
      Proyecto(
        id: proyectoFilosofia,
        nombre: 'Ética Aplicada',
        descripcion: 'Ética de la investigación, sesgos algorítmicos y bioética.',
        creadoEn: ahora.subtract(const Duration(days: 31)),
        modificadoEn: ahora.subtract(const Duration(days: 2)),
      ),
      Proyecto(
        id: proyectoHistoria,
        nombre: 'Historia Intelectual',
        descripcion:
            'Tradición fenomenológica y hermenéutica en la historia de la filosofía.',
        creadoEn: ahora.subtract(const Duration(days: 18)),
        modificadoEn: ahora.subtract(const Duration(days: 5)),
      ),
    ];
  }

  /// Nueve etiquetas: ocho en uso repartidas entre notas de distintos proyectos
  /// y una («Bibliografía») que queda sin asignar para que la pantalla de
  /// etiquetas muestre un contador en cero.
  static List<Etiqueta> etiquetas() {
    return const <Etiqueta>[
      Etiqueta(id: etMetodologia, nombre: 'Metodología'),
      Etiqueta(id: etHistoriaMental, nombre: 'Historia Mental'),
      Etiqueta(id: etEtica, nombre: 'Ética'),
      Etiqueta(id: etFilosofia, nombre: 'Filosofía'),
      Etiqueta(id: etTesis, nombre: 'Tesis'),
      Etiqueta(id: etContexto, nombre: 'Contexto'),
      Etiqueta(id: etRevision, nombre: 'Revisión'),
      Etiqueta(id: etPendiente, nombre: 'Pendiente'),
      Etiqueta(id: etBibliografia, nombre: 'Bibliografía'),
    ];
  }

  static List<Nota> notas(DateTime ahora) {
    return <Nota>[
      // ------------------------------------------------------------ Psicología
      Nota(
        id: 'n_01',
        proyectoId: proyectoPsicologia,
        titulo: 'Teoría de la carga cognitiva',
        descripcion: _cargaCognitiva,
        creadoEn: ahora.subtract(const Duration(days: 12)),
        modificadoEn: ahora.subtract(const Duration(days: 1)),
        etiquetasIds: const <String>{etMetodologia, etHistoriaMental},
      ),
      Nota(
        id: 'n_02',
        proyectoId: proyectoPsicologia,
        titulo: 'Ciclo atencional',
        descripcion: _cicloAtencional,
        creadoEn: ahora.subtract(const Duration(days: 9)),
        modificadoEn: ahora.subtract(const Duration(hours: 20)),
        etiquetasIds: const <String>{etHistoriaMental},
      ),
      Nota(
        id: 'n_03',
        proyectoId: proyectoPsicologia,
        titulo: 'Memoria de trabajo',
        descripcion: _memoriaTrabajo,
        creadoEn: ahora.subtract(const Duration(days: 7)),
        modificadoEn: ahora.subtract(const Duration(days: 3)),
        etiquetasIds: const <String>{etRevision, etHistoriaMental},
      ),
      Nota(
        id: 'n_04',
        proyectoId: proyectoPsicologia,
        titulo: 'Errores en el razonamiento inductivo',
        descripcion: _razonamientoInductivo,
        creadoEn: ahora.subtract(const Duration(days: 6)),
        modificadoEn: ahora.subtract(const Duration(days: 4)),
        etiquetasIds: const <String>{etTesis, etRevision},
      ),
      Nota(
        id: 'n_05',
        proyectoId: proyectoPsicologia,
        titulo: 'Diferencias individuales en la atención',
        descripcion:
            'Apunte de apoyo para la sección introductoria del capítulo 2. '
            'Pendiente: recuperar la tabla original de los anexos del artículo '
            'antes de cerrar el apartado.',
        creadoEn: ahora.subtract(const Duration(days: 5)),
        modificadoEn: ahora.subtract(const Duration(days: 4, hours: 3)),
        etiquetasIds: const <String>{etContexto},
      ),
      Nota(
        id: 'n_06',
        proyectoId: proyectoPsicologia,
        titulo: 'Bucle atencional',
        descripcion:
            'Un bucle atencional describe la secuencia que se repite mientras una '
            'persona sostiene un mismo objeto de pensamiento durante varios '
            'segundos.',
        creadoEn: ahora.subtract(const Duration(days: 4)),
        modificadoEn: ahora.subtract(const Duration(days: 3, hours: 5)),
        etiquetasIds: const <String>{etHistoriaMental, etTesis},
      ),

      // ------------------------------------------------------------- Filosofía
      Nota(
        id: 'n_07',
        proyectoId: proyectoFilosofia,
        titulo: 'Ética en la investigación',
        descripcion: _eticaInvestigacion,
        creadoEn: ahora.subtract(const Duration(days: 14)),
        modificadoEn: ahora.subtract(const Duration(days: 2)),
        etiquetasIds: const <String>{etEtica, etTesis},
      ),
      Nota(
        id: 'n_08',
        proyectoId: proyectoFilosofia,
        titulo: 'Sesgos algorítmicos',
        descripcion: _sesgosAlgoritmicos,
        creadoEn: ahora.subtract(const Duration(days: 11)),
        modificadoEn: ahora.subtract(const Duration(days: 1, hours: 8)),
        etiquetasIds: const <String>{etEtica, etRevision},
      ),
      Nota(
        id: 'n_09',
        proyectoId: proyectoFilosofia,
        titulo: 'Consentimiento informado',
        descripcion: _consentimientoInformado,
        creadoEn: ahora.subtract(const Duration(days: 10)),
        modificadoEn: ahora.subtract(const Duration(days: 8)),
        etiquetasIds: const <String>{etEtica, etContexto},
      ),
      Nota(
        id: 'n_10',
        proyectoId: proyectoFilosofia,
        titulo: 'Paradigma bioético',
        descripcion:
            'Cuadro comparativo de los cuatro paradigmas que articula el autor de '
            'referencia. Necesito contrastar las definiciones con la fuente '
            'primaria antes de citarlo en el trabajo final.',
        creadoEn: ahora.subtract(const Duration(days: 8)),
        modificadoEn: ahora.subtract(const Duration(days: 6)),
        etiquetasIds: const <String>{etEtica, etFilosofia},
      ),

      // -------------------------------------------------------------- Historia
      Nota(
        id: 'n_11',
        proyectoId: proyectoHistoria,
        titulo: 'La tradición fenomenológica',
        descripcion: _fenomenologia,
        creadoEn: ahora.subtract(const Duration(days: 15)),
        modificadoEn: ahora.subtract(const Duration(days: 5)),
        etiquetasIds: const <String>{etFilosofia, etHistoriaMental},
      ),
      Nota(
        id: 'n_12',
        proyectoId: proyectoHistoria,
        titulo: 'Hermenéutica histórica',
        descripcion: _hermeneutica,
        creadoEn: ahora.subtract(const Duration(days: 13)),
        modificadoEn: ahora.subtract(const Duration(days: 9)),
        etiquetasIds: const <String>{etFilosofia, etContexto},
      ),
      Nota(
        id: 'n_13',
        proyectoId: proyectoHistoria,
        titulo: 'Historicidad y contexto',
        descripcion: _historicidad,
        creadoEn: ahora.subtract(const Duration(days: 10)),
        modificadoEn: ahora.subtract(const Duration(days: 7)),
        etiquetasIds: const <String>{etHistoriaMental, etFilosofia},
      ),
      Nota(
        id: 'n_14',
        proyectoId: proyectoHistoria,
        titulo: 'Medio siglo XIX',
        descripcion:
            'Apunte breve sobre la recomposición del saber en el siglo XIX. Sin '
            'etiquetas todavía: sirve de contrapeso para comprobar que la app '
            'muestra notas sin clasificar.',
        creadoEn: ahora.subtract(const Duration(days: 4)),
        modificadoEn: ahora.subtract(const Duration(days: 3, hours: 8)),
      ),
      Nota(
        id: 'n_15',
        proyectoId: proyectoHistoria,
        titulo: 'Fuentes primarias por confirmar',
        descripcion: '',
        creadoEn: ahora.subtract(const Duration(days: 2)),
        modificadoEn: ahora.subtract(const Duration(hours: 14)),
        etiquetasIds: const <String>{etPendiente, etRevision},
      ),
    ];
  }
}

const String _cargaCognitiva = '''
La teoría de la carga cognitiva sostiene que el rendimiento en tareas de
aprendizaje depende de la cantidad de información que la memoria de trabajo
puede manipular de forma simultánea, y no de su capacidad total. Esa diferencia
explica por qué dividir una tarea en pasos intermedios suele conducir a mejores
resultados que ejecutarla de un solo golpe.

En el marco de Sweller se distinguen tres tipos de carga: la carga intrínseca,
que depende de la interactividad de los elementos; la carga extrínseca, que
aparece cuando el diseño de la instrucción exige un esfuerzo innecesario; y la
carga constructiva, asociada al esfuerzo de construir esquemas por parte de
quien estudia.

Para el proyecto importa una consecuencia metodológica: al comparar dos
materiales idénticos salvo en su formato no estamos midiendo una capacidad
cognitiva del participante, sino la eficiencia de la instrucción. Por eso los
protocolos de investigación que hemos revisado insistían en igualar el número de
palabras, el número de pasos y el tiempo de exposición, y en reportar por
separado el rendimiento en tareas de comprensión y en tareas de recuerdo.

Queda abierto el debate sobre si la carga intrínseca puede reducirse mediante
conocimiento previo: los datos disponibles apuntan a que el efecto del
conocimiento previo se recupera con la práctica deliberada y no con la
exposición repetida. Conviene registrar esta objeción en el capítulo de marco
teórico para no presentar la teoría como un consenso cerrado.
''';

const String _cicloAtencional = '''
El ciclo atencional describe la secuencia que se repite mientras una persona
sostiene un mismo objeto de pensamiento durante varios segundos. Cada iteración
incluye una fase de alerta, una de profundización y una de abandono que reabre
el ciclo desde un punto distinto.

Lo relevante para nuestra investigación no es la duración del ciclo sino su
irregularidad: la variabilidad entre iteraciones parece predecir el
reaprendizaje con más eficacia que el tiempo total dedicado a la tarea. Esto
sugiere que registrar únicamente el tiempo total puede ocultar diferencias
reales entre participantes, especialmente en tareas de lectura larga donde las
interrupciones son frecuentes.

El apunte conecta con la nota sobre teoría de la carga cognitiva: si la atención
es cíclica, la carga intrínseca de un texto no es una propiedad fija del texto,
sino una propiedad de la relación entre el texto y la fase del ciclo en la que
se encuentra el lector en cada momento.
''';

const String _memoriaTrabajo = '''
La memoria de trabajo es el sistema de capacidad limitada que mantiene
información disponible para razonar y manipular a corto plazo. La descripción de
Baddeley la descompone en un almacén fonológico, uno visuoespacial y un centro
ejecutivo que coordina la atención; el modelo de recursos duales añade
atención sostenida y atención selectiva.

Para el trabajo con participantes humanos, el dato más útil de la literatura es
que el rendimiento en tareas de n-back sigue una curva en forma de techo después
de los dos o tres bloques iniciales. De ahí que los protocolos que comparan
condiciones exijan equivalentes visuales o verbales desde el principio.

Merece la pena comprobar si los materiales usados en el experimento piloto
mantienen la misma dificultad aparente entre versiones. Si una versión tiene más
elementos por pantalla, el descenso en el último bloque puede deberse a la
interferencia y no a la fatiga del participante.
''';

const String _razonamientoInductivo = '''
La inducción permite pasar de observaciones particulares a una generalización,
y su ejecución se ha estudiado en el marco de los sesgos cognitivos. El sesgo de
confirmación aparece cuando la decisión de aceptar evidencia depende de la
conclusión que el sujeto ya sostiene.

Se ha observado que presentar primero las instancias negativas de una regla
reduce la fuerza del sesgo, mientras que presentar primero las positivas la
incrementa. Este hallazgo sugiere que el orden de exposición es una variable
manipulable con efectos medibles sobre el razonamiento de los participantes.

El apunte se conserva como evidencia de tesis porque enlaza directamente con el
marco conceptual del proyecto: si aceptamos que el razonamiento inductivo es
sesgado, un diseño experimental que no controle el orden de los ejemplos está
midiendo una propiedad del estímulo y no del sujeto.
''';

const String _eticaInvestigacion = '''
La ética de la investigación agrupa las obligaciones que asumen quienes producen
conocimiento sobre personas: obtener consentimiento informado, proteger la
confidencialidad, evitar el daño innecesario y declarar los conflictos de
interés. Estos compromisos se articulan en códigos deontológicos, pero su
cumplimiento real depende de la cultura institucional de cada laboratorio.

El principio del consentimiento informado es el más discutido. La versión
estándar exige que el sujeto comprenda el objetivo, los procedimientos, los
riesgos y las alternativas razonables. Sin embargo, la comprensión real depende
de un lenguaje que muchas veces es técnico; de ahí que los estudios sobre el
malentendido terapéutico insistan en que la firma del formulario no garantiza por
sí sola una comprensión genuina.

En bioética se distingue además entre validez y calidad del consentimiento. Un
consentimiento puede ser formalmente válido, por haber sido firmado por una
persona competente, y sin embargo tener baja calidad si la información
proporcionada fue parcial o innecesariamente cargada de jerga. Esta distinción
resulta útil cuando se evalúa un protocolo ya aprobado por un comité y se quiere
saber si su aplicación al caso concreto respeta el espíritu de la norma.

El proyecto debe recoger estas distinciones en un apartado propio, porque
condensarlas en una nota breve impide mostrar el razonamiento. La revisión de
literatura confirma que la discusión no es reciente: los debates sobre el
reclutamiento de participantes ya aparecen en la documentación de los años
setenta y ochenta.
''';

const String _sesgosAlgoritmicos = '''
Un sistema que clasifica documentos, personas o imágenes puede reproducir y
amplificar los sesgos presentes en sus datos de entrenamiento. El caso más citado
sigue siendo un detector comercial que clasificaba profesiones consideradas
neutras con una tasa de error muy superior para ciertos grupos, lo que ilustra
que el problema no es el algoritmo en abstracto sino la representación que
aprende.

La literatura distingue al menos tres mecanismos: sesgo en los datos, sesgo de
diseño introducido por las decisiones humanas del equipo y sesgo emergente por la
interacción del sistema con su entorno. Distinguirlos importa porque cada uno
admite una mitigación distinta: corregir los datos, documentar las decisiones o
auditar el comportamiento en producción.

Aplicado a nuestro proyecto, la implicancia es que una revisión sistemática no
puede limitarse a medir cuánto error tiene un sistema, sino que debe informar
cómo se distribuye ese error entre subgrupos. Un promedio aceptable puede
ocultar un desempeño inaceptable en un grupo concreto.

Queda pendiente consultar la bibliografía del apunte de consentimiento
informado: parte de los casos que motivan la regulación europea provienen del
ámbito sanitario y no del comercial.
''';

const String _consentimientoInformado = '''
El consentimiento informado es la expresión de que el sujeto comprende en qué
consiste su participación y ha aceptado de forma libre. En la práctica
documental se descompone en tres partes: la información que se proporciona, la
comprensión que el sujeto demuestra y la decisión que adopta.

La información debe ser comprensible, es decir adecuada al nivel de conocimiento
del sujeto, y proporcionada en un momento en que no exista presión para decidir.
La compresión se usa legítimamente en formularios extensos siempre que no oculte
información material sobre riesgos y alternativas.

La comprensión es donde fallan la mayoría de los protocolos: los sujetos
tienden a interpretar la participación temporal como una transcendencia mínima
que les afecta, cuando los datos pueden seguir siendo identificables durante
años. Documentar este malentendido es más útil que repetir la definición
normativa del requisito.

Finalmente, la decisión debe ser revocable sin justificación. Una vez otorgado
el consentimiento, el sujeto puede retirarlo y destruir los datos no completados,
lo cual obliga al equipo a diseñar una arquitectura que permita esa eliminación
selectiva en lugar de una conservación indefinida.
''';

const String _fenomenologia = '''
La tradición fenomenológica aparece a finales del siglo XIX como una reacción
frente a la naturalización de la experiencia: frente a explicar los fenómenos,
propone describir su estructura tal como aparece a la conciencia.

Brentano caracteriza la psicología como descriptiva y se apoya en el análisis de
la conciencia, en el que se distingue la presentación de un objeto del juicio
sobre ese objeto. La fenomenología husserliana radicaliza el punto: no se trata
de describir una experiencia, sino de sus condiciones de posibilidad.

Su legado para la historia intelectual es doble. Por un lado proporciona un
método, la reducción, que permite tematizar el propio marco conceptual de la
investigación. Por otro legitima la pregunta por las estructuras que hacen
posibles las categorías que la teoría emplea.

Nuestro uso del término tiene que ser prudente: hablar de la experiencia
fenomenológica dentro de un experimento cognitivo puede sugerir que se mide una
vivencia cuando en realidad se mide una tarea. Conviene distinguir el recurso a
la fenomenología como tradición filosófica del recurso a la fenomenología como
método empírico.
''';

const String _hermeneutica = '''
La hermenéutica histórica sostiene que el sentido de un texto no es un contenido
fijo que la investigación rescate intacto, sino una relación entre texto y
contexto que se establece en cada lectura. Gadamer resume esta idea con la
noción de fusión de horizontes: comprender es poner en diálogo el horizonte del
interpretante y el de la tradición.

Contra la lectura romanticizada aparece la crítica según la cual la tradición se
transmite por selección y no por depósito. En el caso de los textos canónicos
de la filosofía del siglo XIX esto implica que la recepción no puede
reconstruirse solo a partir del original, sino a partir de las lecturas que
hicieron legibles sus categorías.

Este principio tiene una consecuencia metodológica: el apunte debe documentar qué
edición se utiliza, quién la tradujo y en qué momento, porque cada una de esas
decisiones modifica el horizonte de lectura. Sin ese registro la cita es imposible
de auditar.
''';

const String _historicidad = '''
Por historicidad se entiende la conciencia de que las categorías del presente se
formaron en un momento concreto y que, por tanto, no son neutras respecto a ese
momento. El término se popularizó desde la filosofía continental y acabó
sirviendo para historiar categorías que se habían presentado como universales.

Aplicado a la historia intelectual, permite explicar por qué cierta terminología
desaparece de los textos de una época sin ser reemplazada de inmediato por otra
equivalente: el concepto queda sin condiciones de uso y se retira del horizonte
compartido de la comunidad académica.

El apunte conecta con la hermenéutica histórica: si el sentido depende de la
fusión de horizontes, entonces historiar una categoría es documentar los cambios
de horizonte en los que dejó de significar lo que significaba. Esta exigencia es
la que impide tratar la historia de la filosofía como una secuencia de
posiciones estables.

Pendiente: verificar si los protocolos de análisis textual que usamos en el
proyecto aplican el mismo criterio de historicidad a sus categorías.
''';