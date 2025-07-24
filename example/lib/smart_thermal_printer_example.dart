import 'package:flutter/material.dart';
import 'package:smart_thermal_printer_flutter/smart_thermal_printer_flutter_lib.dart';

class SmartThermalPrinterExample extends StatefulWidget {
  const SmartThermalPrinterExample({super.key});

  @override
  State<SmartThermalPrinterExample> createState() =>
      _SmartThermalPrinterExampleState();
}

class _SmartThermalPrinterExampleState
    extends State<SmartThermalPrinterExample> {
  /// Generar datos de prueba para imprimir
  Future<List<int>> _generateSampleReceipt() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text(
      'SMART THERMAL PRINTER',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        bold: true,
      ),
    );

    bytes += generator.text(
      'Ejemplo de Impresión',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.hr();

    // Content
    bytes += generator.text('Producto: Café Premium');
    bytes += generator.text('Cantidad: 2');
    bytes += generator.text('Precio: \$10.00');
    bytes += generator.hr();
    bytes += generator.text(
      'Total: \$20.00',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    );

    bytes += generator.feed(2);
    bytes += generator.text(
      'Gracias por su compra!',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Thermal Printer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Lista de impresoras disponibles
          Expanded(
            flex: 2,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: ThermalPrinterList(
                onPrinterConnected: (printer) {
                  print('Impresora conectada: ${printer.name}');
                },
                onConnectionFailed: (error) {
                  print('Error de conexión: $error');
                },
                emptyText:
                    'No se encontraron impresoras.\nAsegúrate de que tu impresora esté encendida.',
              ),
            ),
          ),

          // Área de control de impresión
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Control de Impresión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón de impresión principal
                      Expanded(
                        child: SmartThermalPrintButton(
                          generatePrintData: _generateSampleReceipt,
                          buttonText: 'Imprimir Recibo',
                          printingText: 'Imprimiendo...',
                          icon: const Icon(Icons.receipt),
                          onPrintCompleted: () {
                            print('Impresión completada exitosamente');
                          },
                          onPrintFailed: (error) {
                            print('Error en impresión: $error');
                          },
                          buttonStyle: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Botón de desconexión
                      const DisconnectPrinterButton(
                        size: 48,
                        color: Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Botón de impresión simple
                  SmartThermalPrintButton(
                    generatePrintData: () async {
                      final profile = await CapabilityProfile.load();
                      final generator = Generator(PaperSize.mm80, profile);
                      List<int> bytes = [];
                      bytes += generator.text('Impresión de prueba simple');
                      bytes += generator.feed(2);
                      bytes += generator.cut();
                      return bytes;
                    },
                    buttonText: 'Impresión Simple',
                    buttonStyle: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    showConnectedPrinter: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
