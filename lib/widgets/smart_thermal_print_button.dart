import 'package:flutter/material.dart';

import '../connection/printer_connection_manager.dart';

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
    if (!_connectionManager.isConnected) {
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

      final success = await _connectionManager.print(
        dataToprint,
        longData: widget.longData,
      );

      if (success) {
        widget.onPrintCompleted?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impresión completada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final error =
            _connectionManager.connectionError ?? 'Error de impresión';
        widget.onPrintFailed?.call(error);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      widget.onPrintFailed?.call(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Conectado: ${connectedPrinter.name ?? 'Impresora'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade800,
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
            onPressed: isConnected && !_isPrinting ? _handlePrint : null,
            style: widget.buttonStyle ??
                ElevatedButton.styleFrom(
                  backgroundColor: isConnected ? Colors.blue : Colors.grey,
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
                : widget.icon ?? const Icon(Icons.print),
            label: Text(
              _isPrinting ? widget.printingText : widget.buttonText,
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
