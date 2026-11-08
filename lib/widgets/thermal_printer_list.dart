import 'dart:async';

import 'package:flutter/material.dart';

import '../connection/printer_connection_manager.dart';
import '../smart_thermal_printer_flutter.dart';
import '../utils/printer.dart';

/// Widget para listar y conectar impresoras térmicas
class ThermalPrinterList extends StatefulWidget {
  /// Lista de tipos de conexión a buscar
  final List<ConnectionType> connectionTypes;

  /// Duración del refresh para búsqueda
  final Duration refreshDuration;

  /// Callback cuando se conecta una impresora
  final Function(Printer printer)? onPrinterConnected;

  /// Callback cuando falla la conexión
  final Function(String error)? onConnectionFailed;

  /// Estilo personalizado para los elementos de la lista
  final BoxDecoration? itemDecoration;

  /// Color del icono de conexión
  final Color? connectionIconColor;

  /// Texto para cuando no hay impresoras. Sin él se usa
  /// [PrinterStrings.noPrintersFound] del idioma actual.
  final String? emptyText;

  const ThermalPrinterList({
    super.key,
    this.connectionTypes = const [ConnectionType.USB, ConnectionType.BLE],
    this.refreshDuration = const Duration(seconds: 2),
    this.onPrinterConnected,
    this.onConnectionFailed,
    this.itemDecoration,
    this.connectionIconColor,
    this.emptyText,
  });

  @override
  State<ThermalPrinterList> createState() => _ThermalPrinterListState();
}

class _ThermalPrinterListState extends State<ThermalPrinterList> {
  late StreamSubscription<List<Printer>> _printersSubscription;
  List<Printer> _printers = [];
  bool _isScanning = false;
  final PrinterConnectionManager _connectionManager =
      PrinterConnectionManager.instance;

  /// Textos del idioma actual (ver [PrinterStrings.of]).
  PrinterStrings _s = PrinterStrings.es;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _s = PrinterStrings.of(context);
  }

  @override
  void initState() {
    super.initState();
    _initPrinterScanning();
    _connectionManager.addListener(_onConnectionStateChanged);
  }

  @override
  void dispose() {
    _printersSubscription.cancel();
    SmartThermalPrinterFlutter.instance.stopScan();
    _connectionManager.removeListener(_onConnectionStateChanged);
    super.dispose();
  }

  void _initPrinterScanning() {
    _printersSubscription =
        SmartThermalPrinterFlutter.instance.devicesStream.listen(
      (printers) {
        if (mounted) {
          setState(() {
            _printers = printers;
          });
        }
      },
    );

    _startScanning();
  }

  void _startScanning() async {
    setState(() {
      _isScanning = true;
    });

    try {
      await SmartThermalPrinterFlutter.instance.getPrinters(
        refreshDuration: widget.refreshDuration,
        connectionTypes: widget.connectionTypes,
        androidUsesFineLocation: true,
      );
    } catch (e) {
      // Error handling
    }
  }

  void _onConnectionStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _connectToPrinter(Printer printer) async {
    final success = await _connectionManager.connectToPrinter(printer);

    if (success) {
      widget.onPrinterConnected?.call(printer);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_s.connectedTo(printer.name ?? _s.unnamedPrinter)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      final error = _connectionManager.connectionError ?? _s.connectionError;
      widget.onConnectionFailed?.call(error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_s.errorDetail(error)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildConnectionTypeIcon(ConnectionType? type) {
    IconData iconData;
    switch (type) {
      case ConnectionType.BLE:
        iconData = Icons.bluetooth;
        break;
      case ConnectionType.USB:
        iconData = Icons.usb;
        break;
      case ConnectionType.NETWORK:
        iconData = Icons.wifi;
        break;
      default:
        iconData = Icons.print;
    }

    return Icon(
      iconData,
      color: widget.connectionIconColor ?? Colors.blue,
      size: 20,
    );
  }

  Widget _buildPrinterTile(Printer printer) {
    final isConnected =
        _connectionManager.connectedPrinter?.address == printer.address;
    final isConnecting = _connectionManager.isConnecting;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: widget.itemDecoration ??
          BoxDecoration(
            color: isConnected ? Colors.green.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isConnected ? Colors.green : Colors.grey.shade300,
              width: isConnected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
      child: ListTile(
        leading: _buildConnectionTypeIcon(printer.connectionType),
        title: Text(
          printer.name ?? _s.unnamedPrinter,
          style: TextStyle(
            fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
            color: isConnected ? Colors.green.shade800 : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (printer.address != null)
              Text(
                _s.addressLabel(printer.address!),
                style: const TextStyle(fontSize: 12),
              ),
            Text(
              _s.typeLabel(
                printer.connectionType?.name ?? _s.unknownConnectionType,
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: isConnected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : isConnecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: () => _connectToPrinter(printer),
                    tooltip: _s.connect,
                  ),
        onTap: isConnected || isConnecting
            ? null
            : () => _connectToPrinter(printer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header con controles
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _s.availablePrinters,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (_isScanning)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _startScanning,
                  tooltip: _s.searchPrinters,
                ),
            ],
          ),
        ),

        // Lista de impresoras
        Expanded(
          child: _printers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.print_disabled,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.emptyText ?? _s.noPrintersFound,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _startScanning,
                        icon: const Icon(Icons.search),
                        label: Text(_s.searchPrinters),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _printers.length,
                  itemBuilder: (context, index) {
                    return _buildPrinterTile(_printers[index]);
                  },
                ),
        ),
      ],
    );
  }
}
