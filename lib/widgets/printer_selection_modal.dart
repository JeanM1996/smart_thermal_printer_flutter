import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../connection/printer_connection_manager.dart';
import '../smart_thermal_printer_flutter.dart';
import '../utils/printer.dart';

/// Widget de menú contextual para seleccionar impresoras
class PrinterSelectionModal extends StatefulWidget {
  /// Callback cuando se conecta una impresora
  final Function(Printer printer)? onPrinterConnected;

  /// Callback cuando falla la conexión
  final Function(String error)? onConnectionFailed;

  /// Tipos de conexión a buscar
  final List<ConnectionType> connectionTypes;

  const PrinterSelectionModal({
    super.key,
    this.onPrinterConnected,
    this.onConnectionFailed,
    this.connectionTypes = const [ConnectionType.USB, ConnectionType.BLE],
  });

  @override
  State<PrinterSelectionModal> createState() => _PrinterSelectionModalState();
}

class _PrinterSelectionModalState extends State<PrinterSelectionModal> {
  List<Printer> _printers = [];
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _connectingPrinterId;
  final PrinterConnectionManager _connectionManager =
      PrinterConnectionManager.instance;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndScan();
  }

  @override
  void dispose() {
    SmartThermalPrinterFlutter.instance.stopScan();
    super.dispose();
  }

  /// Verificar permisos y empezar a buscar impresoras
  Future<void> _checkPermissionsAndScan() async {
    // Verificar y solicitar permisos de Bluetooth si es necesario
    if (widget.connectionTypes.contains(ConnectionType.BLE)) {
      final hasPermission = await _requestBluetoothPermissions();
      if (!hasPermission) {
        if (mounted) {
          _showPermissionDialog();
        }
        return;
      }
    }

    await _startScanning();
  }

  /// Solicitar permisos de Bluetooth
  Future<bool> _requestBluetoothPermissions() async {
    try {
      // Verificar si Bluetooth está disponible
      if (await FlutterBluePlus.isSupported == false) {
        return false;
      }

      // Verificar si Bluetooth está encendido
      if (await FlutterBluePlus.adapterState.first !=
          BluetoothAdapterState.on) {
        // Intentar encender Bluetooth
        await FlutterBluePlus.turnOn();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mostrar diálogo de permisos
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos necesarios'),
        content: const Text(
          'Para buscar impresoras Bluetooth, necesitamos permisos de Bluetooth y ubicación. '
          'Por favor, activa Bluetooth y otorga los permisos necesarios.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Cerrar el modal también
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkPermissionsAndScan(); // Intentar de nuevo
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// Empezar búsqueda de impresoras
  Future<void> _startScanning() async {
    setState(() {
      _isScanning = true;
      _printers = [];
    });

    try {
      // Configurar el stream de dispositivos
      SmartThermalPrinterFlutter.instance.devicesStream.listen(
        (printers) {
          if (mounted) {
            setState(() {
              _printers = printers;
            });
          }
        },
      );

      // Empezar búsqueda
      await SmartThermalPrinterFlutter.instance.getPrinters(
        refreshDuration: const Duration(seconds: 2),
        connectionTypes: widget.connectionTypes,
        androidUsesFineLocation: true,
      );

      // Detener búsqueda después de 15 segundos
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && _isScanning) {
          setState(() {
            _isScanning = false;
          });
          SmartThermalPrinterFlutter.instance.stopScan();
        }
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  /// Conectar a una impresora
  Future<void> _connectToPrinter(Printer printer) async {
    setState(() {
      _isConnecting = true;
      _connectingPrinterId = printer.address;
    });

    try {
      final success = await _connectionManager.connectToPrinter(printer);

      if (success) {
        widget.onPrinterConnected?.call(printer);
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar modal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Conectado a ${printer.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final error = _connectionManager.connectionError ?? 'Error de conexión';
        widget.onConnectionFailed?.call(error);
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
      widget.onConnectionFailed?.call(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _connectingPrinterId = null;
        });
      }
    }
  }

  Widget _buildConnectionTypeIcon(ConnectionType? type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case ConnectionType.BLE:
        iconData = Icons.bluetooth;
        iconColor = Colors.blue;
        break;
      case ConnectionType.USB:
        iconData = Icons.usb;
        iconColor = Colors.orange;
        break;
      case ConnectionType.NETWORK:
        iconData = Icons.wifi;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.print;
        iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor, size: 24);
  }

  Widget _buildPrinterTile(Printer printer) {
    final isConnecting =
        _isConnecting && _connectingPrinterId == printer.address;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildConnectionTypeIcon(printer.connectionType),
        title: Text(
          printer.name ?? 'Impresora sin nombre',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (printer.address != null)
              Text(
                'Dirección: ${printer.address}',
                style: const TextStyle(fontSize: 12),
              ),
            Text(
              'Tipo: ${printer.connectionType?.name ?? 'Desconocido'}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: isConnecting ? null : () => _connectToPrinter(printer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.print, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Seleccionar Impresora',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isScanning)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _startScanning,
                    tooltip: 'Buscar de nuevo',
                  ),
              ],
            ),
          ),

          // Lista de impresoras o estado vacío
          Flexible(
            child: _printers.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isScanning ? Icons.search : Icons.print_disabled,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning
                              ? 'Buscando impresoras...'
                              : 'No se encontraron impresoras',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (!_isScanning) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _startScanning,
                            icon: const Icon(Icons.search),
                            label: const Text('Buscar impresoras'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _printers.length,
                    itemBuilder: (context, index) {
                      return _buildPrinterTile(_printers[index]);
                    },
                  ),
          ),

          // Footer con botón de cancelar
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
