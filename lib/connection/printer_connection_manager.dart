import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../Others/other_printers_manager.dart';
import '../Windows/window_printer_manager.dart';
import '../smart_thermal_printer_flutter.dart';
import '../utils/printer.dart';

/// Gestor de conexiones persistentes para impresoras térmicas
class PrinterConnectionManager {
  PrinterConnectionManager._();

  static PrinterConnectionManager? _instance;
  static PrinterConnectionManager get instance {
    _instance ??= PrinterConnectionManager._();
    return _instance!;
  }

  Printer? _connectedPrinter;
  bool _isConnecting = false;
  bool _isReconnecting = false;
  String? _connectionError;
  Timer? _connectionCheckTimer;
  StreamSubscription? _connectionStateSubscription;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  final List<Function()> _listeners = [];

  /// Agregar listener para cambios de estado
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  /// Remover listener
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  /// Notificar a todos los listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Impresora actualmente conectada
  Printer? get connectedPrinter => _connectedPrinter;

  /// Estado de conexión
  bool get isConnected => _connectedPrinter != null;

  /// Estado de conexión en progreso
  bool get isConnecting => _isConnecting;

  /// Estado de reconexión en progreso
  bool get isReconnecting => _isReconnecting;

  /// Error de conexión
  String? get connectionError => _connectionError;

  /// Conectar a una impresora y mantener la conexión persistente
  Future<bool> connectToPrinter(Printer printer) async {
    if (_isConnecting) return false;

    _isConnecting = true;
    _isReconnecting = false;
    _connectionError = null;
    _reconnectAttempts = 0;
    _notifyListeners();

    debugPrint(
        'Intentando conectar a impresora: ${printer.name} (${printer.address})');

    try {
      bool success;
      if (Platform.isWindows) {
        success = await WindowPrinterManager.instance.connect(printer);
      } else {
        success = await OtherPrinterManager.instance.connect(printer);
      }

      if (success) {
        _connectedPrinter = printer;
        _startConnectionMonitoring();
        _startConnectionStateListening();
        _connectionError = null;
        _reconnectAttempts = 0;
        debugPrint('Conexión exitosa a: ${printer.name}');
      } else {
        _connectionError = 'Failed to connect to printer';
        debugPrint('Error: Failed to connect to printer');
      }

      _isConnecting = false;
      _notifyListeners();
      return success;
    } catch (e) {
      _connectionError = 'Error connecting to printer: $e';
      debugPrint('Error conectando a impresora: $e');
      _isConnecting = false;
      _notifyListeners();
      return false;
    }
  }

  /// Desconectar de la impresora actual
  Future<void> disconnect() async {
    if (_connectedPrinter == null) return;

    _stopConnectionMonitoring();
    _stopConnectionStateListening();

    try {
      if (Platform.isWindows) {
        // Windows disconnect implementation
      } else {
        await OtherPrinterManager.instance.disconnect(_connectedPrinter!);
      }
    } catch (e) {
      debugPrint('Error desconectando de impresora: $e');
    }

    _connectedPrinter = null;
    _connectionError = null;
    _reconnectAttempts = 0;
    _isReconnecting = false;
    _notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Impresión controlada
  // ---------------------------------------------------------------------------

  /// Tiempo máximo que se espera a la impresora antes de dar el envío por
  /// fallido. No se reintenta solo: un reintento automático puede sacar el
  /// comprobante dos veces.
  static const Duration printTimeout = Duration(seconds: 45);

  bool _isPrinting = false;
  PrintErrorInfo? _lastPrintError;
  final Map<String, DateTime> _recentPrints = {};

  /// `true` mientras hay un envío a la impresora en curso (en cualquier
  /// botón de la app).
  bool get isPrinting => _isPrinting;

  /// Por qué falló la última impresión, explicado para el usuario
  /// (`null` si la última salió bien).
  PrintErrorInfo? get lastPrintError => _lastPrintError;

  PrintErrorInfo _fail(Object error) {
    final info = describePrintError(error);
    _lastPrintError = info;
    _connectionError = info.message;
    return info;
  }

  /// Huella del contenido (FNV-1a 32 bits), para reconocer el mismo
  /// comprobante sin guardar sus bytes.
  static String fingerprint(List<int> bytes) {
    var hash = 0x811c9dc5;
    for (final b in bytes) {
      hash ^= b & 0xff;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return '${bytes.length}:${hash.toRadixString(16)}';
  }

  /// Cuándo se imprimió con éxito [key] por última vez (dentro de [window]).
  DateTime? lastPrintedAt(String key,
      {Duration window = const Duration(minutes: 10)}) {
    final at = _recentPrints[key];
    if (at == null) return null;
    if (DateTime.now().difference(at) > window) {
      _recentPrints.remove(key);
      return null;
    }
    return at;
  }

  /// Imprimir datos usando la conexión activa.
  ///
  /// - Una sola impresión a la vez en toda la app: si ya hay una en curso,
  ///   devuelve `false` sin enviar nada (doble toque, dos botones).
  /// - Con [printTimeout]: si la impresora no responde, se reporta error en
  ///   vez de quedar colgado.
  /// - Si sale bien, registra [key] (o la huella de [bytes]) para que la UI
  ///   pueda pedir confirmación antes de una reimpresión.
  Future<bool> print(
    List<int> bytes, {
    bool longData = false,
    String? key,
  }) async {
    if (_isPrinting) {
      _fail('Ya hay una impresión en curso');
      debugPrint('Impresión ignorada: ya hay una en curso');
      return false;
    }
    if (_connectedPrinter == null) {
      _fail('No hay impresora conectada');
      debugPrint('Error: No printer connected');
      _notifyListeners();
      return false;
    }

    debugPrint(
        'Iniciando impresión con ${bytes.length} bytes, longData: $longData');

    _isPrinting = true;
    _notifyListeners();
    try {
      await SmartThermalPrinterFlutter.instance
          .printData(_connectedPrinter!, bytes, longData: longData)
          .timeout(printTimeout);
      _recentPrints[key ?? fingerprint(bytes)] = DateTime.now();
      _connectionError = null;
      _lastPrintError = null;
      debugPrint('Impresión completada exitosamente');
      return true;
    } on TimeoutException catch (e) {
      _fail(e);
      debugPrint('Timeout de impresión');
      return false;
    } catch (e) {
      _fail(e);
      debugPrint('Error de impresión: $e');
      return false;
    } finally {
      _isPrinting = false;
      _notifyListeners();
    }
  }

  /// Verificar el estado de la conexión
  Future<bool> checkConnection() async {
    if (_connectedPrinter == null) return false;

    try {
      // Verificación más robusta según el tipo de conexión
      if (_connectedPrinter!.connectionType == ConnectionType.BLE) {
        // Para BLE, verificar el estado real de Bluetooth
        bool isConnected =
            await OtherPrinterManager.instance.isConnected(_connectedPrinter!);
        return isConnected;
      } else if (_connectedPrinter!.connectionType == ConnectionType.USB) {
        // Para USB, verificar si el dispositivo sigue disponible
        bool isConnected =
            await OtherPrinterManager.instance.isConnected(_connectedPrinter!);
        return isConnected;
      }
      return true;
    } catch (e) {
      debugPrint('Error verificando conexión: $e');
      return false;
    }
  }

  /// Intentar reconectar automáticamente
  Future<void> _attemptReconnect() async {
    if (_connectedPrinter == null ||
        _isReconnecting ||
        _reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;
    debugPrint(
        'Intento de reconexión #$_reconnectAttempts/$_maxReconnectAttempts');
    _notifyListeners();

    try {
      bool success;
      if (Platform.isWindows) {
        success =
            await WindowPrinterManager.instance.connect(_connectedPrinter!);
      } else {
        success =
            await OtherPrinterManager.instance.connect(_connectedPrinter!);
      }

      if (success) {
        debugPrint('Reconexión exitosa');
        _connectionError = null;
        _reconnectAttempts = 0;
        _isReconnecting = false;
        _startConnectionStateListening(); // Reiniciar el listener
        _notifyListeners();
      } else {
        _isReconnecting = false;
        if (_reconnectAttempts >= _maxReconnectAttempts) {
          _connectionError =
              'Failed to reconnect after $_maxReconnectAttempts attempts';
          _connectedPrinter = null;
          debugPrint('Se agotaron los intentos de reconexión');
        } else {
          // Esperar antes del próximo intento
          await Future.delayed(Duration(seconds: 2 * _reconnectAttempts));
          _attemptReconnect();
        }
        _notifyListeners();
      }
    } catch (e) {
      _isReconnecting = false;
      debugPrint('Error durante reconexión: $e');
      if (_reconnectAttempts >= _maxReconnectAttempts) {
        _connectionError = 'Reconnection failed: $e';
        _connectedPrinter = null;
      } else {
        // Esperar antes del próximo intento
        await Future.delayed(Duration(seconds: 2 * _reconnectAttempts));
        _attemptReconnect();
      }
      _notifyListeners();
    }
  }

  /// Iniciar escucha del estado de conexión para BLE
  void _startConnectionStateListening() {
    _stopConnectionStateListening();

    if (_connectedPrinter?.connectionType == ConnectionType.BLE) {
      try {
        _connectionStateSubscription =
            _connectedPrinter!.connectionState.listen(
          (state) {
            debugPrint('Estado de conexión BLE: $state');
            if (state.name == 'disconnected' && _connectedPrinter != null) {
              debugPrint('Conexión BLE perdida, intentando reconectar...');
              _attemptReconnect();
            }
          },
          onError: (error) {
            debugPrint('Error en connectionState stream: $error');
          },
        );
      } catch (e) {
        debugPrint('Error iniciando listener de estado de conexión: $e');
      }
    }
  }

  /// Detener escucha del estado de conexión
  void _stopConnectionStateListening() {
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
  }

  /// Iniciar monitoreo de conexión
  void _startConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 5), // Verificar cada 5 segundos
      (_) async {
        if (_connectedPrinter != null && !_isReconnecting) {
          final isStillConnected = await checkConnection();
          if (!isStillConnected) {
            debugPrint('Conexión perdida detectada en monitoreo');
            _attemptReconnect();
          }
        }
      },
    );
  }

  /// Detener monitoreo de conexión
  void _stopConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
  }

  void dispose() {
    _stopConnectionMonitoring();
    _stopConnectionStateListening();
    _listeners.clear();
  }
}
