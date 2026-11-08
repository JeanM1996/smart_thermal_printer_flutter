import 'dart:async';

import '../l10n/printer_strings.dart';

/// Error de impresión explicado para el usuario: qué pasó y qué hacer.
class PrintErrorInfo {
  const PrintErrorInfo(
    this.title,
    this.hint, {
    this.mayHavePrinted = false,
    this.kind,
  });

  /// Qué pasó, en una línea.
  final String title;

  /// Qué puede hacer el usuario.
  final String hint;

  /// `true` cuando no se sabe si el papel salió (timeout, se cortó a mitad):
  /// la UI debe pedir revisar antes de reintentar para no duplicar.
  final bool mayHavePrinted;

  /// Qué error es, si lo reconoció el plugin. Permite volver a armar el texto
  /// en otro idioma con [localized]. `null` en errores propios de la app.
  final PrintErrorKind? kind;

  /// El mismo error con los textos de [strings]. Si no tiene [kind] (texto
  /// propio de la app) se devuelve tal cual.
  PrintErrorInfo localized(PrinterStrings strings) {
    final k = kind;
    return k == null ? this : strings.error(k);
  }

  /// Texto completo para SnackBars y callbacks.
  String get message => '$title. $hint';

  @override
  String toString() => message;
}

/// Tipos de error que el plugin reconoce y sabe explicar.
enum PrintErrorKind {
  timeout(mayHavePrinted: true),
  busy,
  bluetoothOff,
  unauthorized,
  disconnected,
  notWritable,
  communicationLost(mayHavePrinted: true),
  networkUnreachable,
  emptyData,
  buildFailed,
  unknown;

  const PrintErrorKind({this.mayHavePrinted = false});

  /// No se sabe si el papel salió: pedir revisar antes de reintentar.
  final bool mayHavePrinted;
}

/// Reconoce el tipo de cualquier error de impresión/conexión.
///
/// Se reconoce por el texto de la excepción porque cada plataforma
/// (flutter_blue_plus, USB, red) lanza tipos distintos. Los textos en
/// español de abajo son los que lanza el propio plugin: no son de UI.
PrintErrorKind classifyPrintError(Object error) {
  if (error is PrintErrorInfo) return error.kind ?? PrintErrorKind.unknown;
  if (error is TimeoutException) return PrintErrorKind.timeout;

  final raw = error.toString().toLowerCase();
  bool has(List<String> words) => words.any(raw.contains);

  if (has(['ya hay una impresión en curso'])) return PrintErrorKind.busy;
  if (has([
    'adapter is off',
    'bluetooth must be turned on',
    'bluetooth is off',
    'poweredoff',
    'powered off',
    'adapterstate.off'
  ])) {
    return PrintErrorKind.bluetoothOff;
  }
  if (has(['unauthorized', 'permission', 'permiso', 'not authorized'])) {
    return PrintErrorKind.unauthorized;
  }
  if (has([
    'no está conectada',
    'not connected',
    'device is disconnected',
    'disconnected',
    'no hay impresora'
  ])) {
    return PrintErrorKind.disconnected;
  }
  if (has(['característica de escritura', 'write characteristic'])) {
    return PrintErrorKind.notWritable;
  }
  if (has(['gatt', 'writecharacteristic', 'write failed', 'error 133'])) {
    return PrintErrorKind.communicationLost;
  }
  if (has(['socket', 'connection refused', 'host', 'network'])) {
    return PrintErrorKind.networkUnreachable;
  }
  if (has(['no hay datos para imprimir'])) return PrintErrorKind.emptyData;
  return PrintErrorKind.unknown;
}

/// Traduce cualquier error de impresión/conexión a un mensaje preciso.
///
/// Los textos salen de [strings]; sin él, de [PrinterStrings.current]
/// (lo fijado en [PrinterStrings.defaults], o el idioma que resolvieron los
/// widgets, o español). Un [PrintErrorInfo] propio de la app (sin `kind`) se
/// devuelve tal cual.
PrintErrorInfo describePrintError(Object error, {PrinterStrings? strings}) {
  final s = strings ?? PrinterStrings.current;
  if (error is PrintErrorInfo) return error.localized(s);
  return s.error(classifyPrintError(error));
}
