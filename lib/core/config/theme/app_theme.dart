import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Tema profesional industrial para MaCElectricos
/// Colores: Azul eléctrico, Gris acero, Blanco, Alertas (rojo/ámbar/verde)
class AppTheme {
  // Paleta de colores industrial
  static const Color _primaryBlue = Color(0xFF0066CC);      // Azul eléctrico principal
  static const Color _primaryBlueLight = Color(0xFF4D94FF); // Azul hover/focus
  static const Color _primaryBlueDark = Color(0xFF004499);  // Azul pressed

  static const Color _steelGrey = Color(0xFF4A4A4A);        // Gris acero (texto principal)
  static const Color _steelGreyLight = Color(0xFF757575);   // Gris medio (texto secundario)
  static const Color _steelGreyLighter = Color(0xFFBDBDBD); // Gris claro (dividers, disabled)
  static const Color _steelGreyLightest = Color(0xFFE0E0E0); // Gris muy claro (fondos secundarios)

  static const Color _surfaceWhite = Color(0xFFFFFFFF);     // Blanco puro
  static const Color _surfaceGrey = Color(0xFFFAFAFA);      // Fondo pantalla

  // Colores semánticos (alertas/estados)
  static const Color _dangerRed = Color(0xFFD32F2F);        // Peligro/Error
  static const Color _warningAmber = Color(0xFFF57F17);     // Advertencia/Pendiente
  static const Color _successGreen = Color(0xFF2E7D32);     // Éxito/Completado
  static const Color _infoBlue = Color(0xFF0277BD);         // Información

  // Colores con transparencia para overlays
  static const Color _overlayDark = Color(0x80000000);      // 50% negro
  static const Color _overlayLight = Color(0x80FFFFFF);     // 50% blanco

  /// Tema Claro (Light) - Principal para trabajo de campo
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _primaryBlue,
      onPrimary: _surfaceWhite,
      primaryContainer: Color(0xFFE3F2FD),
      onPrimaryContainer: _primaryBlueDark,
      secondary: _steelGrey,
      onSecondary: _surfaceWhite,
      secondaryContainer: _steelGreyLightest,
      onSecondaryContainer: _steelGrey,
      tertiary: _infoBlue,
      onTertiary: _surfaceWhite,
      error: _dangerRed,
      onError: _surfaceWhite,
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: _dangerRed,
      surface: _surfaceWhite,
      onSurface: _steelGrey,
      surfaceContainerHighest: _surfaceGrey,
      onSurfaceVariant: _steelGreyLight,
      outline: _steelGreyLighter,
      outlineVariant: _steelGreyLightest,
      shadow: Color(0x1A000000),
      scrim: _overlayDark,
      inverseSurface: _steelGrey,
      onInverseSurface: _surfaceWhite,
      inversePrimary: _primaryBlueLight,
    ),

    // Tipografía industrial - legible en exteriores
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: _steelGrey,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _steelGrey,
        letterSpacing: -0.25,
        height: 1.25,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _steelGrey,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: _steelGrey,
        height: 1.35,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _steelGrey,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _steelGrey,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _steelGrey,
        letterSpacing: 0.15,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _steelGrey,
        letterSpacing: 0.1,
        height: 1.45,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _steelGreyLight,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _steelGrey,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _steelGrey,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _steelGreyLight,
        letterSpacing: 0.4,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _steelGrey,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _steelGreyLight,
        letterSpacing: 0.5,
        height: 1.45,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: _steelGreyLight,
        letterSpacing: 0.5,
        height: 1.5,
      ),
    ),

    // AppBar profesional
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      backgroundColor: _surfaceWhite,
      foregroundColor: _steelGrey,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _steelGrey,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(
        color: _steelGrey,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: _steelGrey,
        size: 24,
      ),
    ),

    // Botones - estilo industrial
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: _primaryBlue,
        foregroundColor: _surfaceWhite,
        disabledBackgroundColor: _steelGreyLighter,
        disabledForegroundColor: _steelGreyLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return _primaryBlueDark.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return _primaryBlueLight.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.focused)) {
              return _primaryBlueLight.withValues(alpha: 0.12);
            }
            return null;
          },
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _primaryBlue,
        foregroundColor: _surfaceWhite,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryBlue,
        side: const BorderSide(color: _primaryBlue, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(64, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input fields - alto contraste para exterior
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        color: _steelGreyLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        color: _steelGreyLighter,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: const TextStyle(
        color: _dangerRed,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        color: _primaryBlue,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _steelGreyLighter, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _steelGreyLighter, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _dangerRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _dangerRed, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _steelGreyLightest, width: 1.5),
      ),
    ),

    // Cards - elevación sutil
    cardTheme: CardThemeData(
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      surfaceTintColor: Colors.transparent,
      color: _surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _steelGreyLightest, width: 1),
      ),
      margin: const EdgeInsets.all(8),
    ),

    // Bottom Navigation
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: _surfaceWhite,
      indicatorColor: _primaryBlue.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _primaryBlue,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _steelGreyLight,
          );
        },
      ),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primaryBlue, size: 24);
          }
          return const IconThemeData(color: _steelGreyLight, size: 24);
        },
      ),
    ),

    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 8,
      shadowColor: Color(0x1A000000),
      surfaceTintColor: Colors.transparent,
      backgroundColor: _surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      modalBarrierColor: _overlayDark,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      elevation: 8,
      shadowColor: const Color(0x1A000000),
      surfaceTintColor: Colors.transparent,
      backgroundColor: _surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _steelGrey,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _steelGrey,
        height: 1.5,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: _steelGreyLightest,
      thickness: 1,
      space: 1,
      indent: 0,
      endIndent: 0,
    ),

    // List Tile
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _steelGrey,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _steelGreyLight,
      ),
      leadingAndTrailingTextStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _steelGreyLight,
      ),
      iconColor: _steelGreyLight,
      textColor: _steelGrey,
      selectedColor: _primaryBlue,
      selectedTileColor: Color(0xFFE3F2FD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: _steelGreyLightest,
      disabledColor: _steelGreyLightest.withValues(alpha: 0.5),
      selectedColor: _primaryBlue.withValues(alpha: 0.12),
      secondarySelectedColor: _primaryBlue,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _steelGrey,
      ),
      secondaryLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _surfaceWhite,
      ),
      brightness: Brightness.light,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _steelGreyLighter),
      ),
      selectedShadowColor: Colors.transparent,
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      backgroundColor: _primaryBlue,
      foregroundColor: _surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      extendedPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _steelGrey,
      contentTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _surfaceWhite,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 4,
      actionTextColor: _primaryBlueLight,
    ),

    // Progress Indicators
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primaryBlue,
      linearTrackColor: _steelGreyLightest,
      circularTrackColor: _steelGreyLightest,
    ),

    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: _primaryBlue,
      inactiveTrackColor: _steelGreyLightest,
      thumbColor: _primaryBlue,
      overlayColor: _primaryBlue.withValues(alpha: 0.12),
      valueIndicatorColor: _primaryBlue,
      valueIndicatorTextStyle: const TextStyle(
        color: _surfaceWhite,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryBlue;
          }
          return _steelGreyLighter;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryBlue.withValues(alpha: 0.3);
          }
          return _steelGreyLightest;
        },
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return null;
          }
          return _steelGreyLighter;
        },
      ),
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryBlue;
          }
          return Colors.transparent;
        },
      ),
      checkColor: WidgetStateProperty.all(_surfaceWhite),
      side: const BorderSide(color: _steelGreyLighter, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),

    // Radio
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryBlue;
          }
          return _steelGreyLight;
        },
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),

    // Tab Bar
    tabBarTheme: TabBarThemeData(
      labelColor: _primaryBlue,
      unselectedLabelColor: _steelGreyLight,
      indicatorColor: _primaryBlue,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
      dividerColor: Colors.transparent,
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.pressed)) {
            return _primaryBlue.withValues(alpha: 0.08);
          }
          return null;
        },
      ),
    ),

    // Expansion Tile
    expansionTileTheme: const ExpansionTileThemeData(
      backgroundColor: _surfaceWhite,
      collapsedBackgroundColor: _surfaceWhite,
      textColor: _steelGrey,
      collapsedTextColor: _steelGrey,
      iconColor: _steelGreyLight,
      collapsedIconColor: _steelGreyLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: _steelGreyLightest),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        side: BorderSide(color: _steelGreyLightest),
      ),
    ),

    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: _steelGrey.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: _surfaceWhite,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      verticalOffset: 24,
      preferBelow: true,
    ),

    // Scaffold
    scaffoldBackgroundColor: _surfaceGrey,

    // Page Transitions
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      },
    ),

    // Visual Density - compacto para más info en pantalla
    visualDensity: VisualDensity.standard,
  );

  /// Tema Oscuro (Dark) - Para trabajo nocturno
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _primaryBlueLight,
      onPrimary: _steelGrey,
      primaryContainer: _primaryBlueDark,
      onPrimaryContainer: _surfaceWhite,
      secondary: _steelGreyLighter,
      onSecondary: _steelGrey,
      secondaryContainer: _steelGrey,
      onSecondaryContainer: _surfaceWhite,
      tertiary: _infoBlue,
      onTertiary: _surfaceWhite,
      error: Color(0xFFEF5350),
      onError: _steelGrey,
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFEF5350),
      surface: Color(0xFF1E1E1E),
      onSurface: _surfaceWhite,
      surfaceContainerHighest: Color(0xFF2C2C2C),
      onSurfaceVariant: _steelGreyLighter,
      outline: Color(0xFF424242),
      outlineVariant: Color(0xFF333333),
      shadow: Color(0x33000000),
      scrim: _overlayDark,
      inverseSurface: _surfaceWhite,
      onInverseSurface: _steelGrey,
      inversePrimary: _primaryBlue,
    ),
    // Hereda el resto de configuraciones del tema claro pero adaptado a dark
    textTheme: lightTheme.textTheme.apply(
      bodyColor: _surfaceWhite,
      displayColor: _surfaceWhite,
    ),
    appBarTheme: lightTheme.appBarTheme.copyWith(
      backgroundColor: const Color(0xFF1E1E1E),
      foregroundColor: _surfaceWhite,
      surfaceTintColor: Colors.transparent,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: lightTheme.cardTheme.copyWith(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF333333)),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    bottomSheetTheme: lightTheme.bottomSheetTheme.copyWith(
      backgroundColor: const Color(0xFF1E1E1E),
    ),
    dialogTheme: lightTheme.dialogTheme.copyWith(
      backgroundColor: const Color(0xFF1E1E1E),
    ),
    navigationBarTheme: lightTheme.navigationBarTheme.copyWith(
      backgroundColor: const Color(0xFF1E1E1E),
      indicatorColor: _primaryBlueLight.withValues(alpha: 0.16),
    ),
    inputDecorationTheme: lightTheme.inputDecorationTheme.copyWith(
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF424242), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF424242), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _primaryBlueLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
      ),
    ),
    chipTheme: lightTheme.chipTheme.copyWith(
      backgroundColor: const Color(0xFF333333),
      disabledColor: const Color(0xFF333333).withValues(alpha: 0.5),
      selectedColor: _primaryBlueLight.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: _surfaceWhite),
      secondaryLabelStyle: const TextStyle(color: _steelGrey),
      side: const BorderSide(color: Color(0xFF424242)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF333333),
      thickness: 1,
    ),
    listTileTheme: lightTheme.listTileTheme.copyWith(
      textColor: _surfaceWhite,
      iconColor: _steelGreyLighter,
      selectedColor: _primaryBlueLight,
      selectedTileColor: _primaryBlueDark.withValues(alpha: 0.3),
    ),
    snackBarTheme: lightTheme.snackBarTheme.copyWith(
      backgroundColor: const Color(0xFF333333),
      contentTextStyle: const TextStyle(color: _surfaceWhite),
    ),
  );
}