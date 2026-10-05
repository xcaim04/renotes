import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta de etiquetas temáticas. Ocho pares (contenedor / tinta) que cumplen
/// contraste AA en modo claro y mantienen legibilidad sobre superficies oscuras.
///
/// `Academic Indigo` y `ReNotes Dark Academia` comparten la misma taxonomía
/// cromática para que una etiqueta conserve su identidad al cambiar de tema.
@immutable
class TagPalette {
  const TagPalette({
    required this.container,
    required this.ink,
    required this.dot,
  });

  final Color container;
  final Color ink;
  final Color dot;

  static const List<TagPalette> claro = <TagPalette>[
    TagPalette(
      container: Color(0xFFE0F2F1),
      ink: Color(0xFF00695C),
      dot: Color(0xFF00897B),
    ), // Teal
    TagPalette(
      container: Color(0xFFFFF8E1),
      ink: Color(0xFFF57F17),
      dot: Color(0xFFFFA000),
    ), // Amber
    TagPalette(
      container: Color(0xFFFFEBEE),
      ink: Color(0xFFC62828),
      dot: Color(0xFFE53935),
    ), // Coral
    TagPalette(
      container: Color(0xFFF3E5F5),
      ink: Color(0xFF6A1B9A),
      dot: Color(0xFF8E24AA),
    ), // Violet
    TagPalette(
      container: Color(0xFFE8F5E9),
      ink: Color(0xFF2E7D32),
      dot: Color(0xFF43A047),
    ), // Green
    TagPalette(
      container: Color(0xFFE3F2FD),
      ink: Color(0xFF1565C0),
      dot: Color(0xFF1E88E5),
    ), // Blue
    TagPalette(
      container: Color(0xFFFCE4EC),
      ink: Color(0xFFAD1457),
      dot: Color(0xFFEC407A),
    ), // Pink
    TagPalette(
      container: Color(0xFFFFF3E0),
      ink: Color(0xFFE65100),
      dot: Color(0xFFFF7043),
    ), // Orange
  ];

  static const List<TagPalette> oscuro = <TagPalette>[
    TagPalette(
      container: Color(0xFF122826),
      ink: Color(0xFF80CBC4),
      dot: Color(0xFF4DB6AC),
    ), // Teal
    TagPalette(
      container: Color(0xFF2C2413),
      ink: Color(0xFFFFE082),
      dot: Color(0xFFFFCA28),
    ), // Amber
    TagPalette(
      container: Color(0xFF2F1918),
      ink: Color(0xFFFFAB91),
      dot: Color(0xFFFF8A65),
    ), // Coral
    TagPalette(
      container: Color(0xFF24182E),
      ink: Color(0xFFCE93D8),
      dot: Color(0xFFB39DDB),
    ), // Violet
    TagPalette(
      container: Color(0xFF16281B),
      ink: Color(0xFFA5D6A7),
      dot: Color(0xFF81C784),
    ), // Green
    TagPalette(
      container: Color(0xFF132236),
      ink: Color(0xFF90CAF9),
      dot: Color(0xFF64B5F6),
    ), // Blue
    TagPalette(
      container: Color(0xFF2E1422),
      ink: Color(0xFFF48FB1),
      dot: Color(0xFFF06292),
    ), // Pink
    TagPalette(
      container: Color(0xFF2D1C13),
      ink: Color(0xFFFFCC80),
      dot: Color(0xFFFFB74D),
    ), // Orange
  ];

  static TagPalette of(String etiquetaId, Brightness brightness) {
    final lista = brightness == Brightness.dark ? oscuro : claro;
    if (etiquetaId.isEmpty) {
      return lista.first;
    }
    final hash = etiquetaId.codeUnits.fold<int>(7, (int acc, int c) {
      return (acc * 31 + c) & 0x7fffffff;
    });
    return lista[hash % lista.length];
  }
}

/// Escalas de espaciado, radio y tipografía extraídas de los DESIGN.md.
abstract final class Insets {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double gutter = 16;
  static const double margin = 16;
}

abstract final class Corners {
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 12;
  static const double xl = 16;
  static const double sheet = 28;
  static const Radius pill = Radius.circular(9999);
}

abstract final class AppTheme {
  // ---------------------------------------------------------------- Paletas
  static const Color _indigo = Color(0xFF3F51B5);
  static const Color _indigoPressed = Color(0xFF303F9F);
  static const Color _indigoContainerLight = Color(0xFFE8EAF6);
  static const Color _indigoOnContainer = Color(0xFF1A237E);

  static const Color _slateLight = Color(0xFFF7F8FC);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _fieldLight = Color(0xFFEEF0F8);
  static const Color _outlineLight = Color(0xFFE0E2EC);
  static const Color _inkLight = Color(0xFF191C20);
  static const Color _inkMutedLight = Color(0xFF44474E);
  static const Color _captionLight = Color(0xFF74777F);

  static const Color _canvasDark = Color(0xFF121316);
  static const Color _surfaceDark = Color(0xFF1A1B20);
  static const Color _panelDark = Color(0xFF202228);
  static const Color _cardDark = Color(0xFF1F1F23);
  static const Color _fieldDark = Color(0xFF16171C);
  static const Color _lineDark = Color(0xFF2C2E38);
  static const Color _inkDark = Color(0xFFE2E2E6);
  static const Color _inkMutedDark = Color(0xFFC4C6D0);
  static const Color _captionDark = Color(0xFF8E9099);

  static const Color _errorLight = Color(0xFFBA1A1A);
  static const Color _errorContainerLight = Color(0xFFFFDAD6);
  static const Color _onErrorContainerLight = Color(0xFF93000A);

  static const Color _primaryDark = Color(0xFF9FA8DA);
  static const Color _secondaryDark = Color(0xFF7986CB);
  static const Color _errorDark = Color(0xFFFFB4AB);

  // ------------------------------------------------------------- Tipografía
  static const String _sans = 'Inter';
  static const String _serif = 'Newsreader';
  static const String _mono = 'JetBrainsMono';

  /// Escala tipográfica. El modo oscuro sustituye la sans por Newsreader en
  /// titulares y JetBrains Mono en metadatos, según `ReNotes Dark Academia`.
  static TextTheme _textTheme(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    final String titulos = dark ? _serif : _sans;
    final String cuerpo = dark ? _sans : _sans;
    final String meta = dark ? _mono : _sans;
    final Color high = dark ? _inkDark : _inkLight;
    final Color medium = dark ? _inkMutedDark : _inkMutedLight;
    final Color subtle = dark ? _captionDark : _captionLight;

    TextStyle t({
      required double size,
      required FontWeight weight,
      required double height,
      required double tracking,
      String? family,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: family ?? cuerpo,
        fontSize: size,
        fontWeight: weight,
        height: height / size,
        letterSpacing: tracking,
        color: color ?? high,
      );
    }

    return TextTheme(
      displayLarge: t(
        family: titulos,
        size: 34,
        weight: FontWeight.w600,
        height: 42,
        tracking: -0.4,
      ),
      headlineLarge: t(
        family: titulos,
        size: dark ? 26 : 22,
        weight: dark ? FontWeight.w400 : FontWeight.w600,
        height: dark ? 34 : 28,
        tracking: -0.2,
      ),
      headlineMedium: t(
        family: titulos,
        size: dark ? 22 : 20,
        weight: dark ? FontWeight.w500 : FontWeight.w600,
        height: dark ? 30 : 26,
        tracking: 0,
      ),
      headlineSmall: t(
        family: titulos,
        size: 18,
        weight: FontWeight.w600,
        height: 24,
        tracking: 0,
      ),
      titleLarge: t(
        family: titulos,
        size: 18,
        weight: dark ? FontWeight.w400 : FontWeight.w600,
        height: 24,
        tracking: 0,
      ),
      titleMedium: t(
        size: 16,
        weight: FontWeight.w600,
        height: 22,
        tracking: 0.1,
      ),
      titleSmall: t(
        size: 14,
        weight: FontWeight.w600,
        height: 20,
        tracking: 0.1,
      ),
      bodyLarge: t(
        size: 16,
        weight: FontWeight.w400,
        height: 26,
        tracking: 0.1,
      ),
      bodyMedium: t(size: 14, weight: FontWeight.w400, height: 22, tracking: 0.15),
      bodySmall: t(
        size: 12,
        weight: FontWeight.w400,
        height: 18,
        tracking: 0.15,
        color: medium,
      ),
      labelLarge: t(
        family: meta,
        size: 13,
        weight: FontWeight.w600,
        height: 18,
        tracking: 0.2,
      ),
      labelMedium: t(
        family: meta,
        size: 11,
        weight: FontWeight.w500,
        height: 16,
        tracking: 0.3,
        color: medium,
      ),
      labelSmall: t(
        family: meta,
        size: 10,
        weight: FontWeight.w500,
        height: 14,
        tracking: 0.4,
        color: subtle,
      ),
    );
  }

  // --------------------------------------------------------------- Esquemas
  static ThemeData light() {
    const ColorScheme cs = ColorScheme(
      brightness: Brightness.light,
      primary: _indigo,
      onPrimary: Colors.white,
      primaryContainer: _indigoContainerLight,
      onPrimaryContainer: _indigoOnContainer,
      secondary: Color(0xFF5C5D72),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFDBDBF4),
      onSecondaryContainer: Color(0xFF444559),
      tertiary: Color(0xFF774E61),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFD8E7),
      onTertiaryContainer: Color(0xFF613B4D),
      error: _errorLight,
      onError: Colors.white,
      errorContainer: _errorContainerLight,
      onErrorContainer: _onErrorContainerLight,
      surface: _slateLight,
      onSurface: _inkLight,
      surfaceContainerHighest: Color(0xFFE4E5EC),
      surfaceContainerHigh: _fieldLight,
      surfaceContainer: Color(0xFFF2F3F7),
      surfaceContainerLow: Color(0xFFF7F8FB),
      surfaceContainerLowest: _cardLight,
      onSurfaceVariant: _inkMutedLight,
      outline: _captionLight,
      outlineVariant: _outlineLight,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF2E3134),
      onInverseSurface: Color(0xFFEFF1F5),
      inversePrimary: Color(0xFFBAC3FF),
    );
    return _base(cs, Brightness.light, _indigoPressed);
  }

  static ThemeData dark() {
    const ColorScheme cs = ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryDark,
      onPrimary: Color(0xFF121316),
      primaryContainer: _secondaryDark,
      onPrimaryContainer: Color(0xFF121316),
      secondary: Color(0xFFBAC3FF),
      onSecondary: Color(0xFF15267B),
      secondaryContainer: Color(0xFF374485),
      onSecondaryContainer: Color(0xFFDEE1FF),
      tertiary: Color(0xFF96A5FF),
      onTertiary: Color(0xFF15267B),
      tertiaryContainer: Color(0xFF2D334D),
      onTertiaryContainer: Color(0xFFDEE1FF),
      error: _errorDark,
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF4A1B1D),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: _canvasDark,
      onSurface: _inkDark,
      surfaceContainerHighest: Color(0xFF383A46),
      surfaceContainerHigh: Color(0xFF30323C),
      surfaceContainer: _cardDark,
      surfaceContainerLow: _panelDark,
      surfaceContainerLowest: _surfaceDark,
      onSurfaceVariant: _inkMutedDark,
      outline: Color(0xFF6E7079),
      outlineVariant: _lineDark,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _inkDark,
      onInverseSurface: Color(0xFF2F3034),
      inversePrimary: Color(0xFF3B4470),
    );
    return _base(cs, Brightness.dark, Color(0xFF6C79C4));
  }

  static ThemeData _base(ColorScheme cs, Brightness b, Color pressed) {
    final bool dark = b == Brightness.dark;
    final TextTheme text = _textTheme(b);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      brightness: b,
      scaffoldBackgroundColor: cs.surface,
      canvasColor: cs.surface,
      fontFamily: _sans,
      textTheme: text,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineMedium,
        iconTheme: IconThemeData(color: cs.onSurface, size: 24),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: _canvasDark,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: _slateLight,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
      ),
      cardTheme: CardThemeData(
        color: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.xl),
          side: BorderSide(
            color: dark ? _lineDark : _outlineLight,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        side: BorderSide.none,
        labelStyle: text.labelMedium!,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.sm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? _fieldDark : _fieldLight,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Insets.md,
          vertical: Insets.md,
        ),
        hintStyle: text.bodyMedium!.copyWith(color: cs.outline),
        labelStyle: text.labelMedium,
        floatingLabelStyle: text.labelMedium!.copyWith(color: cs.primary),
        border: _inputBorder(cs.outlineVariant),
        enabledBorder: _inputBorder(
          dark ? _lineDark : _outlineLight,
        ),
        focusedBorder: _inputBorder(cs.primary, width: 2),
        errorBorder: _inputBorder(cs.error, width: 1.5),
        focusedErrorBorder: _inputBorder(cs.error, width: 2),
        errorStyle: text.labelSmall!.copyWith(color: cs.error),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.lg),
          ),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.lg),
          ),
          side: BorderSide(color: cs.outlineVariant),
          foregroundColor: cs.onSurface,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Corners.sm),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: dark ? _secondaryDark : _indigo,
        foregroundColor: dark ? const Color(0xFF121316) : Colors.white,
        elevation: 3,
        extendedTextStyle: text.labelLarge!.copyWith(
          color: dark ? const Color(0xFF121316) : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.xl),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: cs.outlineVariant,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Corners.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.xl + 8),
          side: BorderSide(color: cs.outlineVariant),
        ),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: text.bodyMedium!.copyWith(
          color: cs.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.lg),
        ),
        insetPadding: const EdgeInsets.all(Insets.md),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: dark ? _surfaceDark : _fieldLight,
        selectedItemColor: dark ? const Color(0xFFDEE1FF) : _indigoOnContainer,
        unselectedItemColor: dark ? _inkMutedDark : _inkMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle: text.labelMedium!.copyWith(
          fontWeight: FontWeight.w700,
          color: dark ? const Color(0xFFDEE1FF) : _indigoOnContainer,
        ),
        unselectedLabelStyle: text.labelMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? _surfaceDark : _fieldLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: dark ? const Color(0xFF2D334D) : _indigoContainerLight,
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(text.labelMedium!),
      ),
      extensions: <ThemeExtension<Object?>>[AppThemeExtension(pressed: pressed)],
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Corners.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Color de estado "pulsado" para los botones filled del tema.
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({required this.pressed});

  final Color pressed;

  @override
  AppThemeExtension copyWith({Color? pressed}) =>
      AppThemeExtension(pressed: pressed ?? this.pressed);

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(pressed: Color.lerp(pressed, other.pressed, t)!);
  }
}