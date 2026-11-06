import 'dart:async';

/// Error de impresión explicado para el usuario: qué pasó y qué hacer.
class PrintErrorInfo {
  const PrintErrorInfo(this.title, this.hint, {this.mayHavePrinted = false});

  /// Qué pasó, en una línea.
  final String title;

  /// Qué puede hacer el usuario.
  final String hint;

  /// `true` cuando no se sabe si el papel salió (timeout, se cortó a mitad):
  /// la UI debe pedir revisar antes de reintentar para no duplicar.
  final bool mayHavePrinted;

  /// Texto completo para SnackBars y callbacks.
  String get message => '$title. $hint';

  @override
  String toString() => message;
}

/// Traduce cualquier error de impresión/conexión a un mensaje preciso.
///
/// Se reconoce por el texto de la excepción porque cada plataforma
/// (flutter_blue_plus, USB, red) lanza tipos distintos.
PrintErrorInfo describePrintError(Object error) {
  if (error is PrintErrorInfo) return error;
  if (error is TimeoutException) {
    return const PrintErrorInfo(
      'La impresora no respondió a tiempo',
      'Revisa si salió el comprobante antes de volver a imprimir.',
      mayHavePrinted: true,
    );
  }

  final raw = error.toString().toLowerCase();
  bool has(List<String> words) => words.any(raw.contains);

  if (has(['ya hay una impresión en curso'])) {
    return const PrintErrorInfo(
      'Ya se está imprimiendo',
      'Espera a que termine el comprobante actual.',
    );
  }
  if (has([
    'adapter is off',
    'bluetooth must be turned on',
    'bluetooth is off',
    'poweredoff',
    'powered off',
    'adapterstate.off'
  ])) {
    return const PrintErrorInfo(
      'El Bluetooth está apagado',
      'Actívalo y vuelve a intentar.',
    );
  }
  if (has(['unauthorized', 'permission', 'permiso', 'not authorized'])) {
    return const PrintErrorInfo(
      'Sin permiso para usar Bluetooth',
      'Autoriza Bluetooth para la app en los ajustes del teléfono.',
    );
  }
  if (has([
    'no está conectada',
    'not connected',
    'device is disconnected',
    'disconnected',
    'no hay impresora'
  ])) {
    return const PrintErrorInfo(
      'La impresora se desconectó',
      'Verifica que esté encendida y cerca, y vuelve a conectarla.',
    );
  }
  if (has(['característica de escritura', 'write characteristic'])) {
    return const PrintErrorInfo(
      'Esta impresora no acepta la impresión',
      'Puede no ser una impresora térmica compatible. Prueba con otra.',
    );
  }
  if (has(['gatt', 'writecharacteristic', 'write failed', 'error 133'])) {
    return const PrintErrorInfo(
      'Se cortó la comunicación con la impresora',
      'Revisa si salió completo el comprobante; si no, apágala y enciéndela.',
      mayHavePrinted: true,
    );
  }
  if (has(['socket', 'connection refused', 'host', 'network'])) {
    return const PrintErrorInfo(
      'No se pudo llegar a la impresora de red',
      'Verifica que esté en la misma red Wi-Fi.',
    );
  }
  if (has(['no hay datos para imprimir'])) {
    return const PrintErrorInfo(
      'No hay nada para imprimir',
      'El comprobante salió vacío; vuelve a abrirlo e intenta otra vez.',
    );
  }
  return const PrintErrorInfo(
    'No se pudo imprimir',
    'Revisa papel y batería de la impresora e intenta de nuevo.',
  );
}
