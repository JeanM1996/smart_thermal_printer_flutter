import 'package:flutter/material.dart';

/// Colores de los widgets del plugin, sacados del `Theme` de la app que los
/// usa: así siguen a su marca y funcionan en claro y en oscuro sin que el
/// plugin conozca la paleta de nadie.
///
/// Los estados (éxito, aviso) no existen en `ColorScheme`: se usan tonos
/// fijos elegidos para leerse en cada modo (≥ 4.5:1 en claro sobre blanco,
/// vivos en oscuro).
@immutable
class PrinterTheme {
  const PrinterTheme._({
    required this.isDark,
    required this.sheet,
    required this.card,
    required this.border,
    required this.primary,
    required this.onPrimary,
    required this.text,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
  });

  factory PrinterTheme.of(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return PrinterTheme._(
      isDark: isDark,
      sheet: theme.bottomSheetTheme.backgroundColor ??
          (isDark ? scheme.surfaceContainerLow : scheme.surface),
      card: isDark ? scheme.surfaceContainerHighest : scheme.surface,
      border: isDark
          ? scheme.outlineVariant
          : scheme.onSurface.withValues(alpha: .08),
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      text: scheme.onSurface,
      textMuted: isDark
          ? scheme.onSurfaceVariant
          : scheme.onSurface.withValues(alpha: .62),
      success: isDark ? const Color(0xFF2BD08B) : const Color(0xFF01814D),
      warning: isDark ? const Color(0xFFFF9653) : const Color(0xFFBB4E07),
      danger: isDark ? const Color(0xFFFF7A86) : const Color(0xFFD0142A),
    );
  }

  final bool isDark;

  /// Fondo del bottom sheet de selección.
  final Color sheet;

  /// Fondo de las filas de impresora.
  final Color card;
  final Color border;
  final Color primary;
  final Color onPrimary;
  final Color text;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color danger;

  /// Tinte suave de [color] para fondos de chips e íconos.
  Color soft(Color color) => color.withValues(alpha: isDark ? .16 : .10);

  /// Relleno sólido de [color] con texto blanco legible encima (SnackBars,
  /// botones de estado). En oscuro los tonos vivos se oscurecen.
  Color fill(Color color) {
    if (!isDark) return color;
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness * .62).clamp(0, 1)).toColor();
  }
}

/// SnackBar de estado con colores del tema.
void showPrinterSnackBar(
  BuildContext context,
  String message, {
  required Color Function(PrinterTheme t) color,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final t = PrinterTheme.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: t.fill(color(t)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
}
