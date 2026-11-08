import 'package:flutter/widgets.dart';

import '../connection/print_error_messages.dart';

/// Texto con un valor (nombre de impresora, error, dirección…).
typedef PrinterTextBuilder = String Function(String value);

/// Texto que depende de una cantidad (minutos, impresoras encontradas…).
typedef PrinterCountBuilder = String Function(int count);

/// Todos los textos que el plugin muestra al usuario.
///
/// Funciona **con o sin** `intl`/gen-l10n: el plugin no depende de ninguno.
///
/// Qué textos usa un widget (en este orden):
/// 1. Un [PrinterStringsScope] por encima (la app arma un [PrinterStrings]
///    desde sus propios ARB/intl, o usa [copyWith] sobre uno incluido).
/// 2. [PrinterStrings.defaults], si la app lo fijó al arrancar.
/// 3. El idioma de `Localizations.maybeLocaleOf(context)`: `es`, `en` o `pt`.
/// 4. Español.
///
/// Incluidos: [PrinterStrings.es] (los textos de siempre), [PrinterStrings.en]
/// y [PrinterStrings.pt] (Brasil).
@immutable
class PrinterStrings {
  const PrinterStrings({
    // Botón de impresión
    required this.printButton,
    required this.printing,
    required this.selectPrinterButton,
    required this.reconnecting,
    required this.connectedChip,
    required this.printerFallbackName,
    required this.waitingReconnection,
    required this.couldNotConnect,
    required this.noPrinterConnected,
    required this.printSuccess,
    required this.reconnectAfterPrintFailed,
    required this.printerDisconnected,
    required this.disconnectPrinter,
    // Confirmación de reimpresión
    required this.reprintTitle,
    required this.reprintMessage,
    required this.justNow,
    required this.minutesAgo,
    required this.reprintConfirm,
    required this.cancel,
    // Diálogo de progreso
    required this.progressSending,
    required this.progressVerifying,
    required this.progressSuccess,
    required this.progressKeepScreenOpen,
    required this.progressRemovePaper,
    required this.progressTryAgain,
    required this.progressMayHavePrinted,
    required this.close,
    required this.retry,
    // Selector de impresoras
    required this.selectPrinterTitle,
    required this.connectedTo,
    required this.connectionError,
    required this.connectFailed,
    required this.connectionErrorDetail,
    required this.searchAgain,
    required this.bluetoothUnavailable,
    required this.searchingNearby,
    required this.searchingFound,
    required this.noResults,
    required this.found,
    required this.searchingPrintersTitle,
    required this.searchingPrintersMessage,
    required this.scanFailedTitle,
    required this.noPrintersFound,
    required this.noPrintersMessage,
    required this.bluetoothOffTitle,
    required this.bluetoothOffMessageIOS,
    required this.bluetoothOffMessage,
    required this.turnOnBluetooth,
    required this.bluetoothPermissionTitle,
    required this.bluetoothPermissionMessageIOS,
    required this.bluetoothPermissionMessage,
    required this.bluetoothUnsupportedMessage,
    required this.preparingBluetoothTitle,
    required this.preparingBluetoothMessage,
    required this.unnamedPrinter,
    required this.unknownConnectionType,
    required this.connectedPill,
    // Lista de impresoras
    required this.availablePrinters,
    required this.searchPrinters,
    required this.connect,
    required this.addressLabel,
    required this.typeLabel,
    required this.errorDetail,
    // Errores de impresión (título + qué hacer)
    required this.errorTimeoutTitle,
    required this.errorTimeoutHint,
    required this.errorBusyTitle,
    required this.errorBusyHint,
    required this.errorBluetoothOffTitle,
    required this.errorBluetoothOffHint,
    required this.errorUnauthorizedTitle,
    required this.errorUnauthorizedHint,
    required this.errorDisconnectedTitle,
    required this.errorDisconnectedHint,
    required this.errorNotWritableTitle,
    required this.errorNotWritableHint,
    required this.errorCommunicationTitle,
    required this.errorCommunicationHint,
    required this.errorNetworkTitle,
    required this.errorNetworkHint,
    required this.errorEmptyTitle,
    required this.errorEmptyHint,
    required this.errorBuildTitle,
    required this.errorBuildHint,
    required this.errorUnknownTitle,
    required this.errorUnknownHint,
  });

  // ---------------------------------------------------------------------------
  // Botón de impresión
  // ---------------------------------------------------------------------------

  /// Etiqueta del botón con impresora conectada. "Imprimir".
  final String printButton;

  /// Etiqueta del botón mientras imprime. "Imprimiendo...".
  final String printing;

  /// Etiqueta del botón sin impresora. "Seleccionar Impresora".
  final String selectPrinterButton;

  /// "Reconectando...".
  final String reconnecting;

  /// Chip de impresora conectada. "Conectado: {nombre}".
  final PrinterTextBuilder connectedChip;

  /// Nombre cuando la impresora no trae uno, en el chip. "Impresora".
  final String printerFallbackName;

  final String waitingReconnection;
  final String couldNotConnect;
  final String noPrinterConnected;
  final String printSuccess;
  final String reconnectAfterPrintFailed;
  final String printerDisconnected;

  /// Tooltip del botón de desconectar.
  final String disconnectPrinter;

  // ---------------------------------------------------------------------------
  // Confirmación de reimpresión
  // ---------------------------------------------------------------------------

  final String reprintTitle;

  /// "Este comprobante ya se imprimió {cuándo}." — recibe [justNow] o
  /// [minutesAgo].
  final PrinterTextBuilder reprintMessage;

  /// "hace un momento".
  final String justNow;

  /// "hace {n} minuto(s)".
  final PrinterCountBuilder minutesAgo;

  final String reprintConfirm;
  final String cancel;

  // ---------------------------------------------------------------------------
  // Diálogo de progreso
  // ---------------------------------------------------------------------------

  final String progressSending;
  final String progressVerifying;
  final String progressSuccess;
  final String progressKeepScreenOpen;
  final String progressRemovePaper;

  /// Pista de error cuando no hay una más precisa.
  final String progressTryAgain;
  final String progressMayHavePrinted;
  final String close;
  final String retry;

  // ---------------------------------------------------------------------------
  // Selector de impresoras
  // ---------------------------------------------------------------------------

  final String selectPrinterTitle;

  /// "Conectado a {nombre}".
  final PrinterTextBuilder connectedTo;

  /// "Error de conexión" (sin detalle).
  final String connectionError;

  /// "No se pudo conectar: {error}".
  final PrinterTextBuilder connectFailed;

  /// "Error de conexión: {error}".
  final PrinterTextBuilder connectionErrorDetail;

  final String searchAgain;
  final String bluetoothUnavailable;
  final String searchingNearby;

  /// "Buscando · {n} encontrada(s)".
  final PrinterCountBuilder searchingFound;
  final String noResults;

  /// "{n} encontrada(s)".
  final PrinterCountBuilder found;

  final String searchingPrintersTitle;
  final String searchingPrintersMessage;
  final String scanFailedTitle;
  final String noPrintersFound;
  final String noPrintersMessage;
  final String bluetoothOffTitle;
  final String bluetoothOffMessageIOS;
  final String bluetoothOffMessage;
  final String turnOnBluetooth;
  final String bluetoothPermissionTitle;
  final String bluetoothPermissionMessageIOS;
  final String bluetoothPermissionMessage;
  final String bluetoothUnsupportedMessage;
  final String preparingBluetoothTitle;
  final String preparingBluetoothMessage;
  final String unnamedPrinter;
  final String unknownConnectionType;

  /// Etiqueta de la impresora actual en la lista. "Conectada".
  final String connectedPill;

  // ---------------------------------------------------------------------------
  // Lista de impresoras (ThermalPrinterList)
  // ---------------------------------------------------------------------------

  final String availablePrinters;
  final String searchPrinters;
  final String connect;

  /// "Dirección: {dirección}".
  final PrinterTextBuilder addressLabel;

  /// "Tipo: {tipo}".
  final PrinterTextBuilder typeLabel;

  /// "Error: {error}".
  final PrinterTextBuilder errorDetail;

  // ---------------------------------------------------------------------------
  // Errores de impresión
  // ---------------------------------------------------------------------------

  final String errorTimeoutTitle;
  final String errorTimeoutHint;
  final String errorBusyTitle;
  final String errorBusyHint;
  final String errorBluetoothOffTitle;
  final String errorBluetoothOffHint;
  final String errorUnauthorizedTitle;
  final String errorUnauthorizedHint;
  final String errorDisconnectedTitle;
  final String errorDisconnectedHint;
  final String errorNotWritableTitle;
  final String errorNotWritableHint;
  final String errorCommunicationTitle;
  final String errorCommunicationHint;
  final String errorNetworkTitle;
  final String errorNetworkHint;
  final String errorEmptyTitle;
  final String errorEmptyHint;
  final String errorBuildTitle;
  final String errorBuildHint;
  final String errorUnknownTitle;
  final String errorUnknownHint;

  /// El error de [kind] en este idioma.
  PrintErrorInfo error(PrintErrorKind kind) {
    final (title, hint) = switch (kind) {
      PrintErrorKind.timeout => (errorTimeoutTitle, errorTimeoutHint),
      PrintErrorKind.busy => (errorBusyTitle, errorBusyHint),
      PrintErrorKind.bluetoothOff => (
          errorBluetoothOffTitle,
          errorBluetoothOffHint
        ),
      PrintErrorKind.unauthorized => (
          errorUnauthorizedTitle,
          errorUnauthorizedHint
        ),
      PrintErrorKind.disconnected => (
          errorDisconnectedTitle,
          errorDisconnectedHint
        ),
      PrintErrorKind.notWritable => (
          errorNotWritableTitle,
          errorNotWritableHint
        ),
      PrintErrorKind.communicationLost => (
          errorCommunicationTitle,
          errorCommunicationHint
        ),
      PrintErrorKind.networkUnreachable => (
          errorNetworkTitle,
          errorNetworkHint
        ),
      PrintErrorKind.emptyData => (errorEmptyTitle, errorEmptyHint),
      PrintErrorKind.buildFailed => (errorBuildTitle, errorBuildHint),
      PrintErrorKind.unknown => (errorUnknownTitle, errorUnknownHint),
    };
    return PrintErrorInfo(
      title,
      hint,
      mayHavePrinted: kind.mayHavePrinted,
      kind: kind,
    );
  }

  // ---------------------------------------------------------------------------
  // Resolución
  // ---------------------------------------------------------------------------

  /// Textos globales de la app. Fijarlo una vez al arrancar (por ejemplo
  /// `PrinterStrings.defaults = PrinterStrings.en;`) gana sobre el idioma
  /// automático; un [PrinterStringsScope] gana sobre esto. `null` = automático.
  static PrinterStrings? defaults;

  static PrinterStrings? _lastResolved;

  /// Textos para código sin `BuildContext` (p. ej. el gestor de conexión):
  /// [defaults], si no los últimos resueltos por [of], si no español.
  static PrinterStrings get current => defaults ?? _lastResolved ?? es;

  /// Textos para [context]: [PrinterStringsScope] → [defaults] → idioma de
  /// `Localizations` → español.
  static PrinterStrings of(BuildContext context) {
    final resolved = context
            .dependOnInheritedWidgetOfExactType<PrinterStringsScope>()
            ?.strings ??
        defaults ??
        forLocale(Localizations.maybeLocaleOf(context));
    _lastResolved = resolved;
    return resolved;
  }

  /// Textos incluidos para [locale] (`es`, `en`, `pt`); cualquier otro → `es`.
  static PrinterStrings forLocale(Locale? locale) {
    switch (locale?.languageCode) {
      case 'en':
        return en;
      case 'pt':
        return pt;
      default:
        return es;
    }
  }

  /// Copia con los textos indicados reemplazados.
  PrinterStrings copyWith({
    String? printButton,
    String? printing,
    String? selectPrinterButton,
    String? reconnecting,
    PrinterTextBuilder? connectedChip,
    String? printerFallbackName,
    String? waitingReconnection,
    String? couldNotConnect,
    String? noPrinterConnected,
    String? printSuccess,
    String? reconnectAfterPrintFailed,
    String? printerDisconnected,
    String? disconnectPrinter,
    String? reprintTitle,
    PrinterTextBuilder? reprintMessage,
    String? justNow,
    PrinterCountBuilder? minutesAgo,
    String? reprintConfirm,
    String? cancel,
    String? progressSending,
    String? progressVerifying,
    String? progressSuccess,
    String? progressKeepScreenOpen,
    String? progressRemovePaper,
    String? progressTryAgain,
    String? progressMayHavePrinted,
    String? close,
    String? retry,
    String? selectPrinterTitle,
    PrinterTextBuilder? connectedTo,
    String? connectionError,
    PrinterTextBuilder? connectFailed,
    PrinterTextBuilder? connectionErrorDetail,
    String? searchAgain,
    String? bluetoothUnavailable,
    String? searchingNearby,
    PrinterCountBuilder? searchingFound,
    String? noResults,
    PrinterCountBuilder? found,
    String? searchingPrintersTitle,
    String? searchingPrintersMessage,
    String? scanFailedTitle,
    String? noPrintersFound,
    String? noPrintersMessage,
    String? bluetoothOffTitle,
    String? bluetoothOffMessageIOS,
    String? bluetoothOffMessage,
    String? turnOnBluetooth,
    String? bluetoothPermissionTitle,
    String? bluetoothPermissionMessageIOS,
    String? bluetoothPermissionMessage,
    String? bluetoothUnsupportedMessage,
    String? preparingBluetoothTitle,
    String? preparingBluetoothMessage,
    String? unnamedPrinter,
    String? unknownConnectionType,
    String? connectedPill,
    String? availablePrinters,
    String? searchPrinters,
    String? connect,
    PrinterTextBuilder? addressLabel,
    PrinterTextBuilder? typeLabel,
    PrinterTextBuilder? errorDetail,
    String? errorTimeoutTitle,
    String? errorTimeoutHint,
    String? errorBusyTitle,
    String? errorBusyHint,
    String? errorBluetoothOffTitle,
    String? errorBluetoothOffHint,
    String? errorUnauthorizedTitle,
    String? errorUnauthorizedHint,
    String? errorDisconnectedTitle,
    String? errorDisconnectedHint,
    String? errorNotWritableTitle,
    String? errorNotWritableHint,
    String? errorCommunicationTitle,
    String? errorCommunicationHint,
    String? errorNetworkTitle,
    String? errorNetworkHint,
    String? errorEmptyTitle,
    String? errorEmptyHint,
    String? errorBuildTitle,
    String? errorBuildHint,
    String? errorUnknownTitle,
    String? errorUnknownHint,
  }) {
    return PrinterStrings(
      printButton: printButton ?? this.printButton,
      printing: printing ?? this.printing,
      selectPrinterButton: selectPrinterButton ?? this.selectPrinterButton,
      reconnecting: reconnecting ?? this.reconnecting,
      connectedChip: connectedChip ?? this.connectedChip,
      printerFallbackName: printerFallbackName ?? this.printerFallbackName,
      waitingReconnection: waitingReconnection ?? this.waitingReconnection,
      couldNotConnect: couldNotConnect ?? this.couldNotConnect,
      noPrinterConnected: noPrinterConnected ?? this.noPrinterConnected,
      printSuccess: printSuccess ?? this.printSuccess,
      reconnectAfterPrintFailed:
          reconnectAfterPrintFailed ?? this.reconnectAfterPrintFailed,
      printerDisconnected: printerDisconnected ?? this.printerDisconnected,
      disconnectPrinter: disconnectPrinter ?? this.disconnectPrinter,
      reprintTitle: reprintTitle ?? this.reprintTitle,
      reprintMessage: reprintMessage ?? this.reprintMessage,
      justNow: justNow ?? this.justNow,
      minutesAgo: minutesAgo ?? this.minutesAgo,
      reprintConfirm: reprintConfirm ?? this.reprintConfirm,
      cancel: cancel ?? this.cancel,
      progressSending: progressSending ?? this.progressSending,
      progressVerifying: progressVerifying ?? this.progressVerifying,
      progressSuccess: progressSuccess ?? this.progressSuccess,
      progressKeepScreenOpen:
          progressKeepScreenOpen ?? this.progressKeepScreenOpen,
      progressRemovePaper: progressRemovePaper ?? this.progressRemovePaper,
      progressTryAgain: progressTryAgain ?? this.progressTryAgain,
      progressMayHavePrinted:
          progressMayHavePrinted ?? this.progressMayHavePrinted,
      close: close ?? this.close,
      retry: retry ?? this.retry,
      selectPrinterTitle: selectPrinterTitle ?? this.selectPrinterTitle,
      connectedTo: connectedTo ?? this.connectedTo,
      connectionError: connectionError ?? this.connectionError,
      connectFailed: connectFailed ?? this.connectFailed,
      connectionErrorDetail:
          connectionErrorDetail ?? this.connectionErrorDetail,
      searchAgain: searchAgain ?? this.searchAgain,
      bluetoothUnavailable: bluetoothUnavailable ?? this.bluetoothUnavailable,
      searchingNearby: searchingNearby ?? this.searchingNearby,
      searchingFound: searchingFound ?? this.searchingFound,
      noResults: noResults ?? this.noResults,
      found: found ?? this.found,
      searchingPrintersTitle:
          searchingPrintersTitle ?? this.searchingPrintersTitle,
      searchingPrintersMessage:
          searchingPrintersMessage ?? this.searchingPrintersMessage,
      scanFailedTitle: scanFailedTitle ?? this.scanFailedTitle,
      noPrintersFound: noPrintersFound ?? this.noPrintersFound,
      noPrintersMessage: noPrintersMessage ?? this.noPrintersMessage,
      bluetoothOffTitle: bluetoothOffTitle ?? this.bluetoothOffTitle,
      bluetoothOffMessageIOS:
          bluetoothOffMessageIOS ?? this.bluetoothOffMessageIOS,
      bluetoothOffMessage: bluetoothOffMessage ?? this.bluetoothOffMessage,
      turnOnBluetooth: turnOnBluetooth ?? this.turnOnBluetooth,
      bluetoothPermissionTitle:
          bluetoothPermissionTitle ?? this.bluetoothPermissionTitle,
      bluetoothPermissionMessageIOS:
          bluetoothPermissionMessageIOS ?? this.bluetoothPermissionMessageIOS,
      bluetoothPermissionMessage:
          bluetoothPermissionMessage ?? this.bluetoothPermissionMessage,
      bluetoothUnsupportedMessage:
          bluetoothUnsupportedMessage ?? this.bluetoothUnsupportedMessage,
      preparingBluetoothTitle:
          preparingBluetoothTitle ?? this.preparingBluetoothTitle,
      preparingBluetoothMessage:
          preparingBluetoothMessage ?? this.preparingBluetoothMessage,
      unnamedPrinter: unnamedPrinter ?? this.unnamedPrinter,
      unknownConnectionType:
          unknownConnectionType ?? this.unknownConnectionType,
      connectedPill: connectedPill ?? this.connectedPill,
      availablePrinters: availablePrinters ?? this.availablePrinters,
      searchPrinters: searchPrinters ?? this.searchPrinters,
      connect: connect ?? this.connect,
      addressLabel: addressLabel ?? this.addressLabel,
      typeLabel: typeLabel ?? this.typeLabel,
      errorDetail: errorDetail ?? this.errorDetail,
      errorTimeoutTitle: errorTimeoutTitle ?? this.errorTimeoutTitle,
      errorTimeoutHint: errorTimeoutHint ?? this.errorTimeoutHint,
      errorBusyTitle: errorBusyTitle ?? this.errorBusyTitle,
      errorBusyHint: errorBusyHint ?? this.errorBusyHint,
      errorBluetoothOffTitle:
          errorBluetoothOffTitle ?? this.errorBluetoothOffTitle,
      errorBluetoothOffHint:
          errorBluetoothOffHint ?? this.errorBluetoothOffHint,
      errorUnauthorizedTitle:
          errorUnauthorizedTitle ?? this.errorUnauthorizedTitle,
      errorUnauthorizedHint:
          errorUnauthorizedHint ?? this.errorUnauthorizedHint,
      errorDisconnectedTitle:
          errorDisconnectedTitle ?? this.errorDisconnectedTitle,
      errorDisconnectedHint:
          errorDisconnectedHint ?? this.errorDisconnectedHint,
      errorNotWritableTitle:
          errorNotWritableTitle ?? this.errorNotWritableTitle,
      errorNotWritableHint: errorNotWritableHint ?? this.errorNotWritableHint,
      errorCommunicationTitle:
          errorCommunicationTitle ?? this.errorCommunicationTitle,
      errorCommunicationHint:
          errorCommunicationHint ?? this.errorCommunicationHint,
      errorNetworkTitle: errorNetworkTitle ?? this.errorNetworkTitle,
      errorNetworkHint: errorNetworkHint ?? this.errorNetworkHint,
      errorEmptyTitle: errorEmptyTitle ?? this.errorEmptyTitle,
      errorEmptyHint: errorEmptyHint ?? this.errorEmptyHint,
      errorBuildTitle: errorBuildTitle ?? this.errorBuildTitle,
      errorBuildHint: errorBuildHint ?? this.errorBuildHint,
      errorUnknownTitle: errorUnknownTitle ?? this.errorUnknownTitle,
      errorUnknownHint: errorUnknownHint ?? this.errorUnknownHint,
    );
  }

  // ---------------------------------------------------------------------------
  // Español (los textos de siempre)
  // ---------------------------------------------------------------------------

  static String _esConnectedChip(String name) => 'Conectado: $name';
  static String _esReprintMessage(String when) =>
      'Este comprobante ya se imprimió $when.';
  static String _esMinutesAgo(int n) =>
      'hace $n ${n == 1 ? 'minuto' : 'minutos'}';
  static String _esConnectedTo(String name) => 'Conectado a $name';
  static String _esConnectFailed(String e) => 'No se pudo conectar: $e';
  static String _esConnectionErrorDetail(String e) => 'Error de conexión: $e';
  static String _esSearchingFound(int n) =>
      'Buscando · $n encontrada${n == 1 ? '' : 's'}';
  static String _esFound(int n) => '$n encontrada${n == 1 ? '' : 's'}';
  static String _esAddress(String a) => 'Dirección: $a';
  static String _esType(String t) => 'Tipo: $t';
  static String _esErrorDetail(String e) => 'Error: $e';

  static const PrinterStrings es = PrinterStrings(
    printButton: 'Imprimir',
    printing: 'Imprimiendo...',
    selectPrinterButton: 'Seleccionar Impresora',
    reconnecting: 'Reconectando...',
    connectedChip: _esConnectedChip,
    printerFallbackName: 'Impresora',
    waitingReconnection: 'Esperando reconexión, intente nuevamente...',
    couldNotConnect: 'No se pudo conectar a la impresora',
    noPrinterConnected: 'No hay impresora conectada',
    printSuccess: 'Impresión completada exitosamente',
    reconnectAfterPrintFailed:
        'Advertencia: Reconexión falló después de impresión',
    printerDisconnected: 'Impresora desconectada',
    disconnectPrinter: 'Desconectar impresora',
    reprintTitle: '¿Imprimir otra copia?',
    reprintMessage: _esReprintMessage,
    justNow: 'hace un momento',
    minutesAgo: _esMinutesAgo,
    reprintConfirm: 'Imprimir copia',
    cancel: 'Cancelar',
    progressSending: 'Enviando a la impresora',
    progressVerifying: 'Imprimiendo comprobante',
    progressSuccess: '¡Comprobante impreso!',
    progressKeepScreenOpen: 'No cierres esta pantalla',
    progressRemovePaper: 'Retira el papel de la impresora',
    progressTryAgain: 'Intenta de nuevo.',
    progressMayHavePrinted: 'Si el papel ya salió completo, no reimprimas.',
    close: 'Cerrar',
    retry: 'Reintentar',
    selectPrinterTitle: 'Seleccionar impresora',
    connectedTo: _esConnectedTo,
    connectionError: 'Error de conexión',
    connectFailed: _esConnectFailed,
    connectionErrorDetail: _esConnectionErrorDetail,
    searchAgain: 'Buscar de nuevo',
    bluetoothUnavailable: 'Bluetooth no disponible',
    searchingNearby: 'Buscando cerca de ti…',
    searchingFound: _esSearchingFound,
    noResults: 'Sin resultados',
    found: _esFound,
    searchingPrintersTitle: 'Buscando impresoras…',
    searchingPrintersMessage:
        'Asegúrate de que la impresora esté encendida y cerca del teléfono.',
    scanFailedTitle: 'No se pudo buscar',
    noPrintersFound: 'No se encontraron impresoras',
    noPrintersMessage:
        'Enciende la impresora, acércala al teléfono y vuelve a buscar.',
    bluetoothOffTitle: 'Bluetooth apagado',
    bluetoothOffMessageIOS: 'Actívalo desde el Centro de control o Ajustes. '
        'Las impresoras aparecerán aquí solas.',
    bluetoothOffMessage: 'Actívalo para buscar impresoras. '
        'Aparecerán aquí en cuanto se encienda.',
    turnOnBluetooth: 'Activar Bluetooth',
    bluetoothPermissionTitle: 'Permiso de Bluetooth necesario',
    bluetoothPermissionMessageIOS:
        'Ve a Ajustes › esta app › Bluetooth y actívalo. '
        'Al volver, la búsqueda empezará sola.',
    bluetoothPermissionMessage: 'Concede el permiso de dispositivos cercanos '
        'en Ajustes. Al volver, la búsqueda empezará sola.',
    bluetoothUnsupportedMessage: 'Este dispositivo no admite Bluetooth.',
    preparingBluetoothTitle: 'Preparando Bluetooth…',
    preparingBluetoothMessage:
        'Si el sistema te pide permiso, acéptalo para buscar impresoras.',
    unnamedPrinter: 'Impresora sin nombre',
    unknownConnectionType: 'Desconocido',
    connectedPill: 'Conectada',
    availablePrinters: 'Impresoras disponibles',
    searchPrinters: 'Buscar impresoras',
    connect: 'Conectar',
    addressLabel: _esAddress,
    typeLabel: _esType,
    errorDetail: _esErrorDetail,
    errorTimeoutTitle: 'La impresora no respondió a tiempo',
    errorTimeoutHint:
        'Revisa si salió el comprobante antes de volver a imprimir.',
    errorBusyTitle: 'Ya se está imprimiendo',
    errorBusyHint: 'Espera a que termine el comprobante actual.',
    errorBluetoothOffTitle: 'El Bluetooth está apagado',
    errorBluetoothOffHint: 'Actívalo y vuelve a intentar.',
    errorUnauthorizedTitle: 'Sin permiso para usar Bluetooth',
    errorUnauthorizedHint:
        'Autoriza Bluetooth para la app en los ajustes del teléfono.',
    errorDisconnectedTitle: 'La impresora se desconectó',
    errorDisconnectedHint:
        'Verifica que esté encendida y cerca, y vuelve a conectarla.',
    errorNotWritableTitle: 'Esta impresora no acepta la impresión',
    errorNotWritableHint:
        'Puede no ser una impresora térmica compatible. Prueba con otra.',
    errorCommunicationTitle: 'Se cortó la comunicación con la impresora',
    errorCommunicationHint:
        'Revisa si salió completo el comprobante; si no, apágala y enciéndela.',
    errorNetworkTitle: 'No se pudo llegar a la impresora de red',
    errorNetworkHint: 'Verifica que esté en la misma red Wi-Fi.',
    errorEmptyTitle: 'No hay nada para imprimir',
    errorEmptyHint:
        'El comprobante salió vacío; vuelve a abrirlo e intenta otra vez.',
    errorBuildTitle: 'No se pudo armar el comprobante',
    errorBuildHint: 'Vuelve a abrirlo e intenta de nuevo.',
    errorUnknownTitle: 'No se pudo imprimir',
    errorUnknownHint:
        'Revisa papel y batería de la impresora e intenta de nuevo.',
  );

  // ---------------------------------------------------------------------------
  // English
  // ---------------------------------------------------------------------------

  static String _enConnectedChip(String name) => 'Connected: $name';
  static String _enReprintMessage(String when) =>
      'This receipt was already printed $when.';
  static String _enMinutesAgo(int n) =>
      '$n ${n == 1 ? 'minute' : 'minutes'} ago';
  static String _enConnectedTo(String name) => 'Connected to $name';
  static String _enConnectFailed(String e) => 'Could not connect: $e';
  static String _enConnectionErrorDetail(String e) => 'Connection error: $e';
  static String _enSearchingFound(int n) => 'Searching · $n found';
  static String _enFound(int n) => '$n found';
  static String _enAddress(String a) => 'Address: $a';
  static String _enType(String t) => 'Type: $t';
  static String _enErrorDetail(String e) => 'Error: $e';

  static const PrinterStrings en = PrinterStrings(
    printButton: 'Print',
    printing: 'Printing...',
    selectPrinterButton: 'Select Printer',
    reconnecting: 'Reconnecting...',
    connectedChip: _enConnectedChip,
    printerFallbackName: 'Printer',
    waitingReconnection: 'Waiting for reconnection, please try again...',
    couldNotConnect: 'Could not connect to the printer',
    noPrinterConnected: 'No printer connected',
    printSuccess: 'Printed successfully',
    reconnectAfterPrintFailed: 'Warning: reconnection failed after printing',
    printerDisconnected: 'Printer disconnected',
    disconnectPrinter: 'Disconnect printer',
    reprintTitle: 'Print another copy?',
    reprintMessage: _enReprintMessage,
    justNow: 'a moment ago',
    minutesAgo: _enMinutesAgo,
    reprintConfirm: 'Print copy',
    cancel: 'Cancel',
    progressSending: 'Sending to the printer',
    progressVerifying: 'Printing receipt',
    progressSuccess: 'Receipt printed!',
    progressKeepScreenOpen: "Don't close this screen",
    progressRemovePaper: 'Take the paper from the printer',
    progressTryAgain: 'Please try again.',
    progressMayHavePrinted:
        "If the paper already came out complete, don't reprint.",
    close: 'Close',
    retry: 'Retry',
    selectPrinterTitle: 'Select printer',
    connectedTo: _enConnectedTo,
    connectionError: 'Connection error',
    connectFailed: _enConnectFailed,
    connectionErrorDetail: _enConnectionErrorDetail,
    searchAgain: 'Search again',
    bluetoothUnavailable: 'Bluetooth unavailable',
    searchingNearby: 'Searching nearby…',
    searchingFound: _enSearchingFound,
    noResults: 'No results',
    found: _enFound,
    searchingPrintersTitle: 'Searching for printers…',
    searchingPrintersMessage:
        'Make sure the printer is turned on and close to the phone.',
    scanFailedTitle: "Couldn't search",
    noPrintersFound: 'No printers found',
    noPrintersMessage:
        'Turn on the printer, bring it close to the phone and search again.',
    bluetoothOffTitle: 'Bluetooth is off',
    bluetoothOffMessageIOS: 'Turn it on from Control Center or Settings. '
        'Printers will show up here automatically.',
    bluetoothOffMessage: 'Turn it on to search for printers. '
        'They will show up here as soon as it is on.',
    turnOnBluetooth: 'Turn on Bluetooth',
    bluetoothPermissionTitle: 'Bluetooth permission required',
    bluetoothPermissionMessageIOS:
        'Go to Settings › this app › Bluetooth and turn it on. '
        'When you come back, the search will start on its own.',
    bluetoothPermissionMessage: 'Grant the nearby devices permission in '
        'Settings. When you come back, the search will start on its own.',
    bluetoothUnsupportedMessage: "This device doesn't support Bluetooth.",
    preparingBluetoothTitle: 'Preparing Bluetooth…',
    preparingBluetoothMessage:
        'If the system asks for permission, accept it to search for printers.',
    unnamedPrinter: 'Unnamed printer',
    unknownConnectionType: 'Unknown',
    connectedPill: 'Connected',
    availablePrinters: 'Available printers',
    searchPrinters: 'Search printers',
    connect: 'Connect',
    addressLabel: _enAddress,
    typeLabel: _enType,
    errorDetail: _enErrorDetail,
    errorTimeoutTitle: "The printer didn't respond in time",
    errorTimeoutHint:
        'Check whether the receipt came out before printing again.',
    errorBusyTitle: 'Already printing',
    errorBusyHint: 'Wait for the current receipt to finish.',
    errorBluetoothOffTitle: 'Bluetooth is off',
    errorBluetoothOffHint: 'Turn it on and try again.',
    errorUnauthorizedTitle: 'No permission to use Bluetooth',
    errorUnauthorizedHint:
        "Allow Bluetooth for the app in the phone's settings.",
    errorDisconnectedTitle: 'The printer disconnected',
    errorDisconnectedHint:
        "Make sure it's on and nearby, then connect it again.",
    errorNotWritableTitle: "This printer doesn't accept the print job",
    errorNotWritableHint:
        'It may not be a compatible thermal printer. Try another one.',
    errorCommunicationTitle: 'Communication with the printer was cut off',
    errorCommunicationHint:
        "Check whether the full receipt came out; if not, turn the printer "
        'off and on again.',
    errorNetworkTitle: "Couldn't reach the network printer",
    errorNetworkHint: "Make sure it's on the same Wi-Fi network.",
    errorEmptyTitle: 'Nothing to print',
    errorEmptyHint: 'The receipt came out empty; open it again and retry.',
    errorBuildTitle: "Couldn't build the receipt",
    errorBuildHint: 'Open it again and try again.',
    errorUnknownTitle: "Couldn't print",
    errorUnknownHint: "Check the printer's paper and battery and try again.",
  );

  // ---------------------------------------------------------------------------
  // Português (Brasil)
  // ---------------------------------------------------------------------------

  static String _ptConnectedChip(String name) => 'Conectado: $name';
  static String _ptReprintMessage(String when) =>
      'Este comprovante já foi impresso $when.';
  static String _ptMinutesAgo(int n) =>
      'há $n ${n == 1 ? 'minuto' : 'minutos'}';
  static String _ptConnectedTo(String name) => 'Conectado a $name';
  static String _ptConnectFailed(String e) => 'Não foi possível conectar: $e';
  static String _ptConnectionErrorDetail(String e) => 'Erro de conexão: $e';
  static String _ptSearchingFound(int n) =>
      'Procurando · $n encontrada${n == 1 ? '' : 's'}';
  static String _ptFound(int n) => '$n encontrada${n == 1 ? '' : 's'}';
  static String _ptAddress(String a) => 'Endereço: $a';
  static String _ptType(String t) => 'Tipo: $t';
  static String _ptErrorDetail(String e) => 'Erro: $e';

  static const PrinterStrings pt = PrinterStrings(
    printButton: 'Imprimir',
    printing: 'Imprimindo...',
    selectPrinterButton: 'Selecionar Impressora',
    reconnecting: 'Reconectando...',
    connectedChip: _ptConnectedChip,
    printerFallbackName: 'Impressora',
    waitingReconnection: 'Aguardando reconexão, tente novamente...',
    couldNotConnect: 'Não foi possível conectar à impressora',
    noPrinterConnected: 'Nenhuma impressora conectada',
    printSuccess: 'Impressão concluída com sucesso',
    reconnectAfterPrintFailed: 'Aviso: a reconexão falhou após a impressão',
    printerDisconnected: 'Impressora desconectada',
    disconnectPrinter: 'Desconectar impressora',
    reprintTitle: 'Imprimir outra via?',
    reprintMessage: _ptReprintMessage,
    justNow: 'há um instante',
    minutesAgo: _ptMinutesAgo,
    reprintConfirm: 'Imprimir via',
    cancel: 'Cancelar',
    progressSending: 'Enviando para a impressora',
    progressVerifying: 'Imprimindo comprovante',
    progressSuccess: 'Comprovante impresso!',
    progressKeepScreenOpen: 'Não feche esta tela',
    progressRemovePaper: 'Retire o papel da impressora',
    progressTryAgain: 'Tente novamente.',
    progressMayHavePrinted: 'Se o papel já saiu completo, não reimprima.',
    close: 'Fechar',
    retry: 'Tentar de novo',
    selectPrinterTitle: 'Selecionar impressora',
    connectedTo: _ptConnectedTo,
    connectionError: 'Erro de conexão',
    connectFailed: _ptConnectFailed,
    connectionErrorDetail: _ptConnectionErrorDetail,
    searchAgain: 'Procurar de novo',
    bluetoothUnavailable: 'Bluetooth indisponível',
    searchingNearby: 'Procurando perto de você…',
    searchingFound: _ptSearchingFound,
    noResults: 'Nenhum resultado',
    found: _ptFound,
    searchingPrintersTitle: 'Procurando impressoras…',
    searchingPrintersMessage:
        'Verifique se a impressora está ligada e perto do celular.',
    scanFailedTitle: 'Não foi possível procurar',
    noPrintersFound: 'Nenhuma impressora encontrada',
    noPrintersMessage:
        'Ligue a impressora, aproxime-a do celular e procure de novo.',
    bluetoothOffTitle: 'Bluetooth desligado',
    bluetoothOffMessageIOS: 'Ative-o pela Central de Controle ou Ajustes. '
        'As impressoras aparecerão aqui sozinhas.',
    bluetoothOffMessage: 'Ative-o para procurar impressoras. '
        'Elas aparecerão aqui assim que ele ligar.',
    turnOnBluetooth: 'Ativar Bluetooth',
    bluetoothPermissionTitle: 'Permissão de Bluetooth necessária',
    bluetoothPermissionMessageIOS:
        'Vá em Ajustes › este app › Bluetooth e ative-o. '
        'Ao voltar, a busca começará sozinha.',
    bluetoothPermissionMessage: 'Conceda a permissão de dispositivos '
        'próximos nas Configurações. Ao voltar, a busca começará sozinha.',
    bluetoothUnsupportedMessage: 'Este dispositivo não tem Bluetooth.',
    preparingBluetoothTitle: 'Preparando o Bluetooth…',
    preparingBluetoothMessage:
        'Se o sistema pedir permissão, aceite para procurar impressoras.',
    unnamedPrinter: 'Impressora sem nome',
    unknownConnectionType: 'Desconhecido',
    connectedPill: 'Conectada',
    availablePrinters: 'Impressoras disponíveis',
    searchPrinters: 'Procurar impressoras',
    connect: 'Conectar',
    addressLabel: _ptAddress,
    typeLabel: _ptType,
    errorDetail: _ptErrorDetail,
    errorTimeoutTitle: 'A impressora não respondeu a tempo',
    errorTimeoutHint:
        'Confira se o comprovante saiu antes de imprimir de novo.',
    errorBusyTitle: 'Já está imprimindo',
    errorBusyHint: 'Aguarde o comprovante atual terminar.',
    errorBluetoothOffTitle: 'O Bluetooth está desligado',
    errorBluetoothOffHint: 'Ative-o e tente novamente.',
    errorUnauthorizedTitle: 'Sem permissão para usar o Bluetooth',
    errorUnauthorizedHint:
        'Autorize o Bluetooth para o app nas configurações do celular.',
    errorDisconnectedTitle: 'A impressora se desconectou',
    errorDisconnectedHint:
        'Verifique se está ligada e por perto, e conecte de novo.',
    errorNotWritableTitle: 'Esta impressora não aceita a impressão',
    errorNotWritableHint:
        'Pode não ser uma impressora térmica compatível. Tente outra.',
    errorCommunicationTitle: 'A comunicação com a impressora caiu',
    errorCommunicationHint:
        'Confira se o comprovante saiu completo; se não, desligue e ligue a '
        'impressora.',
    errorNetworkTitle: 'Não foi possível alcançar a impressora de rede',
    errorNetworkHint: 'Verifique se está na mesma rede Wi-Fi.',
    errorEmptyTitle: 'Não há nada para imprimir',
    errorEmptyHint:
        'O comprovante saiu vazio; abra-o de novo e tente outra vez.',
    errorBuildTitle: 'Não foi possível montar o comprovante',
    errorBuildHint: 'Abra-o de novo e tente novamente.',
    errorUnknownTitle: 'Não foi possível imprimir',
    errorUnknownHint:
        'Confira o papel e a bateria da impressora e tente de novo.',
  );
}

/// Fija los textos del plugin para todo lo que esté debajo.
///
/// Envuelve el `MaterialApp.builder` (o cualquier subárbol) y pasa un
/// [PrinterStrings] armado con las traducciones de la app:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => PrinterStringsScope(
///     strings: PrinterStrings.es.copyWith(printButton: 'Imprimir recibo'),
///     child: child!,
///   ),
/// )
/// ```
class PrinterStringsScope extends InheritedWidget {
  const PrinterStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  final PrinterStrings strings;

  /// El [PrinterStrings] del scope más cercano, o `null` si no hay ninguno.
  static PrinterStrings? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<PrinterStringsScope>()
      ?.strings;

  @override
  bool updateShouldNotify(PrinterStringsScope oldWidget) =>
      strings != oldWidget.strings;
}
