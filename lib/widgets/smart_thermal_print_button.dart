import 'package:flutter/material.dart';

import '../connection/printer_connection_manager.dart';
import '../utils/printer.dart';
import 'printer_selection_modal.dart';

/// Widget de botón para impresión rápida con conexión persistente
class SmartThermalPrintButton extends StatefulWidget {
  /// Datos a imprimir en bytes
  final List<int>? printData;

  /// Función para generar los datos de impresión
  final Future<List<int>> Function()? generatePrintData;

  /// Texto del botón
  final String buttonText;

  /// Texto cuando está imprimiendo
  final String printingText;

  /// Estilo del botón
  final ButtonStyle? buttonStyle;

  /// Icono del botón
  final Widget? icon;

  /// Callback cuando se completa la impresión
  final Function()? onPrintCompleted;

  /// Callback cuando falla la impresión
  final Function(String error)? onPrintFailed;

  /// Si los datos son largos (para configuración de impresión)
  final bool longData;

  /// Mostrar el nombre de la impresora conectada
  final bool showConnectedPrinter;

  /// Altura del botón
  final double? height;

  /// Auto-abrir modal de selección de impresora si no hay conexión
  final bool autoOpenPrinterSelection;

  /// Tipos de conexión a buscar en el modal automático
  final List<ConnectionType> connectionTypes;

  /// Callback cuando se conecta una impresora desde el modal
  final Function(Printer printer)? onPrinterConnected;

  const SmartThermalPrintButton({
    super.key,
    this.printData,
    this.generatePrintData,
    this.buttonText = 'Imprimir',
    this.printingText = 'Imprimiendo...',
    this.buttonStyle,
    this.icon,
    this.onPrintCompleted,
    this.onPrintFailed,
    this.longData = false,
    this.showConnectedPrinter = true,
    this.height,
    this.autoOpenPrinterSelection = true,
    this.connectionTypes = const [ConnectionType.USB, ConnectionType.BLE],
    this.onPrinterConnected,
  }) : assert(printData != null || generatePrintData != null,
            'Debe proporcionar printData o generatePrintData');

  @override
  State<SmartThermalPrintButton> createState() =>
      _SmartThermalPrintButtonState();
}

class _SmartThermalPrintButtonState extends State<SmartThermalPrintButton> {
  final PrinterConnectionManager _connectionManager =
      PrinterConnectionManager.instance;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _connectionManager.addListener(_onConnectionStateChanged);
  }

  @override
  void dispose() {
    _connectionManager.removeListener(_onConnectionStateChanged);
    super.dispose();
  }

  void _onConnectionStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handlePrint() async {
    // Si está reconectando, esperar a que termine
    if (_connectionManager.isReconnecting) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Esperando reconexión, intente nuevamente...'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Si no hay impresora conectada, abrir modal de selección automáticamente
    if (!_connectionManager.isConnected) {
      if (widget.autoOpenPrinterSelection) {
        bool printerConnected = false;

        final selectedPrinter = await _showPrinterSelectionModal();

        // Verificar si se conectó una impresora
        if (selectedPrinter != null) {
          // Esperar un poco más para que el estado se propague completamente
          await Future.delayed(const Duration(milliseconds: 1000));
          printerConnected = _connectionManager.isConnected;

          // Forzar actualización de la UI
          if (mounted) {
            setState(() {});
          }
        }

        if (!printerConnected) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo conectar a la impresora'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return; // El usuario canceló o no se conectó
        }
        // Si se conectó, continuar con la impresión automáticamente
      } else {
        // Comportamiento original: mostrar error
        widget.onPrintFailed?.call('No hay impresora conectada');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay impresora conectada'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // Proceder con la impresión
    await _performPrint();
  }

  /// Mostrar modal de selección de impresora
  Future<Printer?> _showPrinterSelectionModal() async {
    final result = await showModalBottomSheet<Printer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: PrinterSelectionModal(
          connectionTypes: widget.connectionTypes,
          onPrinterConnected: (printer) {
            widget.onPrinterConnected?.call(printer);
            // Cerrar modal y devolver el printer conectado
            Navigator.of(context).pop(printer);
          },
          onConnectionFailed: widget.onPrintFailed,
        ),
      ),
    );

    // Si se seleccionó una impresora, forzar actualización del estado
    if (result != null && mounted) {
      setState(() {});
    }

    return result;
  }

  /// Realizar la impresión real
  Future<void> _performPrint() async {
    // Verificar nuevamente la conexión antes de imprimir
    if (!_connectionManager.isConnected) {
      const error = 'No hay impresora conectada al momento de imprimir';
      widget.onPrintFailed?.call(error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      List<int> dataToprint;

      if (widget.printData != null) {
        dataToprint = widget.printData!;
      } else {
        dataToprint = await widget.generatePrintData!();
      }

      if (dataToprint.isEmpty) {
        throw Exception('No hay datos para imprimir');
      }

      debugPrint(
          'Iniciando impresión con ${dataToprint.length} bytes de datos');

      final success = await _connectionManager.print(
        dataToprint,
        longData: widget.longData,
      );

      if (success) {
        widget.onPrintCompleted?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impresión completada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final error = _connectionManager.connectionError ??
            'Error desconocido de impresión';
        widget.onPrintFailed?.call(error);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error de impresión: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      final errorMessage = 'Error durante la impresión: $e';
      debugPrint(errorMessage);
      widget.onPrintFailed?.call(errorMessage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  /// Obtiene el texto del botón según el estado de conexión
  String _getButtonText(bool isConnected) {
    if (_isPrinting) {
      return widget.printingText;
    }

    if (_connectionManager.isReconnecting) {
      return 'Reconectando...';
    }

    if (isConnected) {
      return widget.buttonText;
    } else {
      return 'Seleccionar Impresora';
    }
  }

  /// Obtiene el icono del botón según el estado de conexión
  Widget _getButtonIcon(bool isConnected) {
    if (_connectionManager.isReconnecting) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (isConnected) {
      return widget.icon ?? const Icon(Icons.print);
    } else {
      return const Icon(Icons.settings_bluetooth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _connectionManager.isConnected;
    final connectedPrinter = _connectionManager.connectedPrinter;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Información de la impresora conectada
        if (widget.showConnectedPrinter &&
            isConnected &&
            connectedPrinter != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _connectionManager.isReconnecting
                  ? Colors.orange.shade50
                  : Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _connectionManager.isReconnecting
                    ? Colors.orange.shade200
                    : Colors.green.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _connectionManager.isReconnecting
                      ? Icons.sync
                      : Icons.check_circle,
                  size: 16,
                  color: _connectionManager.isReconnecting
                      ? Colors.orange.shade600
                      : Colors.green.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _connectionManager.isReconnecting
                      ? 'Reconectando...'
                      : 'Conectado: ${connectedPrinter.name ?? 'Impresora'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _connectionManager.isReconnecting
                        ? Colors.orange.shade800
                        : Colors.green.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Botón de impresión
        SizedBox(
          height: widget.height ?? 50,
          child: ElevatedButton.icon(
            onPressed: (!_isPrinting && !_connectionManager.isReconnecting)
                ? _handlePrint
                : null,
            style: widget.buttonStyle ??
                ElevatedButton.styleFrom(
                  backgroundColor: _connectionManager.isReconnecting
                      ? Colors.orange
                      : (isConnected ? Colors.blue : Colors.orange),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            icon: _isPrinting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : _getButtonIcon(isConnected),
            label: Text(
              _getButtonText(isConnected),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget de botón para desconectar la impresora
class DisconnectPrinterButton extends StatefulWidget {
  /// Tamaño del botón
  final double size;

  /// Color del botón
  final Color? color;

  /// Callback cuando se desconecta
  final Function()? onDisconnected;

  const DisconnectPrinterButton({
    super.key,
    this.size = 36,
    this.color,
    this.onDisconnected,
  });

  @override
  State<DisconnectPrinterButton> createState() =>
      _DisconnectPrinterButtonState();
}

class _DisconnectPrinterButtonState extends State<DisconnectPrinterButton> {
  final PrinterConnectionManager _connectionManager =
      PrinterConnectionManager.instance;

  @override
  void initState() {
    super.initState();
    _connectionManager.addListener(_onConnectionStateChanged);
  }

  @override
  void dispose() {
    _connectionManager.removeListener(_onConnectionStateChanged);
    super.dispose();
  }

  void _onConnectionStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleDisconnect() async {
    await _connectionManager.disconnect();
    widget.onDisconnected?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impresora desconectada'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_connectionManager.isConnected) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: _handleDisconnect,
      icon: Icon(
        Icons.link_off,
        size: widget.size * 0.6,
        color: widget.color ?? Colors.red,
      ),
      style: IconButton.styleFrom(
        backgroundColor: (widget.color ?? Colors.red).withValues(alpha: 0.1),
        fixedSize: Size(widget.size, widget.size),
      ),
      tooltip: 'Desconectar impresora',
    );
  }
}
