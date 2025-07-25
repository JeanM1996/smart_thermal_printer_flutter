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
  String? _connectionError;
  Timer? _connectionCheckTimer;

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

  /// Error de conexión
  String? get connectionError => _connectionError;

  /// Conectar a una impresora y mantener la conexión persistente
  Future<bool> connectToPrinter(Printer printer) async {
    if (_isConnecting) return false;

    _isConnecting = true;
    _connectionError = null;
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
        _connectionError = null;
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

    try {
      if (Platform.isWindows) {
        // Windows disconnect implementation
      } else {
        await OtherPrinterManager.instance.disconnect(_connectedPrinter!);
      }
    } catch (e) {
      // Error disconnecting from printer
    }

    _connectedPrinter = null;
    _connectionError = null;
    _notifyListeners();
  }

  /// Imprimir datos usando la conexión activa
  Future<bool> print(List<int> bytes, {bool longData = false}) async {
    if (_connectedPrinter == null) {
      _connectionError = 'No printer connected';
      debugPrint('Error: No printer connected');
      _notifyListeners();
      return false;
    }

    debugPrint(
        'Iniciando impresión con ${bytes.length} bytes, longData: $longData');

    try {
      await SmartThermalPrinterFlutter.instance.printData(
        _connectedPrinter!,
        bytes,
        longData: longData,
      );
      debugPrint('Impresión completada exitosamente');
      return true;
    } catch (e) {
      _connectionError = 'Print error: $e';
      debugPrint('Error de impresión: $e');
      _notifyListeners();
      return false;
    }
  }

  /// Verificar el estado de la conexión
  Future<bool> checkConnection() async {
    if (_connectedPrinter == null) return false;

    try {
      // Intento básico de verificación de conexión
      // Esto puede variar según el tipo de conexión
      if (_connectedPrinter!.connectionType == ConnectionType.BLE) {
        // Para BLE, podríamos verificar el estado de Bluetooth
        return _connectedPrinter!.isConnected ?? false;
      } else if (_connectedPrinter!.connectionType == ConnectionType.USB) {
        // Para USB, verificar si el dispositivo sigue disponible
        return true; // Simplificado por ahora
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Iniciar monitoreo de conexión
  void _startConnectionMonitoring() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) async {
        if (_connectedPrinter != null) {
          final isStillConnected = await checkConnection();
          if (!isStillConnected) {
            _connectionError = 'Connection lost';
            _connectedPrinter = null;
            _notifyListeners();
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
    _listeners.clear();
  }
}
