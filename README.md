# Smart Thermal Printer Flutter

Un plugin avanzado de Flutter para impresión en impresoras térmicas con gestión inteligente de conexiones y widgets de UI pre-construidos.

![Visits Badge](https://badges.pufler.dev/visits/jeanpaulmosqueraarevalo/smart_thermal_printer_flutter)

Package para todos los servicios de impresora térmica en Android, iOS, macOS, Windows con funcionalidades avanzadas de gestión de conexión.

## ✨ Características Principales

- 🔄 **Conexión Persistente**: Mantiene la conexión activa para impresión rápida
- 🖨️ **Múltiples Tipos de Conexión**: USB, Bluetooth y Red
- 🎨 **Widgets Pre-construidos**: Lista de impresoras y botones de impresión listos para usar
- 🚀 **Impresión Rápida**: Interface optimizada para impresión inmediata
- 🔧 **Gestión Automática**: Monitoreo automático del estado de conexión
- 📱 **Cross-platform**: Compatible con Android, iOS, Windows, macOS y Linux

## 🚀 Soporte Actual

| Servicio                        | Android | iOS | macOS | Windows |
| ------------------------------ | :-----: | :-: | :---: | :-----: |
| Bluetooth                      | ✅      | ✅  | ✅    | ✅      |
| USB                            | ✅      |     | ✅    | ✅      |
| BLE                            | ✅      | ✅  | ✅    | ✅      |
| WiFi                           | ✅      | ✅  | ✅    | ✅      |
| **Conexión Persistente**      | ✅      | ✅  | ✅    | ✅      |
| **Widgets UI**                | ✅      | ✅  | ✅    | ✅      |

## 📦 Instalación

Agrega esto a tu `pubspec.yaml`:

```yaml
dependencies:
  smart_thermal_printer_flutter: ^2.0.0
```

Luego ejecuta:

```bash
flutter pub get
```

## 🔧 Configuración Inicial

### Android

Agrega los permisos necesarios en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS

Agrega en `ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Esta app necesita Bluetooth para conectar con impresoras térmicas</string>
```

## 📖 Uso Básico

### 1. Importar el package

```dart
import 'package:smart_thermal_printer_flutter/smart_thermal_printer_flutter_lib.dart';
```

### 2. Instancia del Plugin

```dart
final smartThermalPrinter = SmartThermalPrinterFlutter.instance;

// Gestión de conexión persistente
final connectionManager = PrinterConnectionManager.instance;
```

### 3. Widget de Lista de Impresoras (NUEVO!)

```dart
ThermalPrinterList(
  onPrinterConnected: (printer) {
    print('Conectado a: ${printer.name}');
  },
  onConnectionFailed: (error) {
    print('Error: $error');
  },
  connectionTypes: [ConnectionType.USB, ConnectionType.BLE],
  emptyText: 'No se encontraron impresoras',
)
```

### 4. Botón de Impresión Inteligente (NUEVO!)

#### Ejemplo Básico
```dart
SmartThermalPrintButton(
  generatePrintData: () async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    
    bytes += generator.text('Mi Recibo');
    bytes += generator.cut();
    
    return bytes;
  },
  buttonText: 'Imprimir Recibo',
  onPrintCompleted: () {
    print('Impresión completada');
  },
)
```

#### Ejemplo Avanzado con Modal Automático
```dart
SmartThermalPrintButton(
  // Datos de impresión pre-generados
  printData: myReceiptData,
  
  // Configuración del botón
  buttonText: 'Imprimir Factura',
  printingText: 'Imprimiendo...',
  icon: Icon(Icons.receipt_long),
  
  // 🚀 NUEVA FUNCIONALIDAD: Modal automático
  autoOpenPrinterSelection: true, // Abre modal si no hay impresora conectada
  connectionTypes: [ConnectionType.BLE, ConnectionType.USB],
  
  // Configuración visual
  buttonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  ),
  
  // Mostrar información de impresora conectada
  showConnectedPrinter: true,
  connectedPrinterStyle: TextStyle(
    fontSize: 12,
    color: Colors.green,
    fontWeight: FontWeight.w500,
  ),
  
  // Callbacks
  onPrintCompleted: () {
    print('✅ Impresión exitosa');
    // Mostrar notificación de éxito
  },
  
  onPrintFailed: (error) {
    print('❌ Error de impresión: $error');
    // Mostrar diálogo de error
  },
  
  onPrinterConnected: (printer) {
    print('🔗 Conectado a: ${printer.name}');
    // Guardar preferencia de impresora
  },
  
  // Para documentos largos
  longData: true,
)
```

#### Ejemplo con Generación Dinámica de Datos
```dart
SmartThermalPrintButton(
  generatePrintData: () async {
    // Generar recibo dinámicamente
    final receipt = await _buildReceipt();
    
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    
    // Header
    bytes += generator.text('FACTURA DE VENTA',
        styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(1);
    
    // Items
    for (var item in receipt.items) {
      bytes += generator.text('${item.name} x${item.quantity}');
      bytes += generator.text('\$${item.price}',
          styles: PosStyles(align: PosAlign.right));
    }
    
    bytes += generator.feed(1);
    bytes += generator.text('TOTAL: \$${receipt.total}',
        styles: PosStyles(bold: true, align: PosAlign.center));
    
    bytes += generator.cut();
    return bytes;
  },
  
  buttonText: 'Imprimir Factura',
  autoOpenPrinterSelection: true,
  
  onPrintCompleted: () async {
    // Marcar factura como impresa
    await _markReceiptAsPrinted();
  },
)
```

### 5. Botón de Desconexión (NUEVO!)

```dart
DisconnectPrinterButton(
  size: 48,
  color: Colors.red,
  onDisconnected: () {
    print('Impresora desconectada');
  },
)
```

## 🎯 Funcionalidades Avanzadas

### Modal Automático de Selección de Impresora

El `SmartThermalPrintButton` incluye una funcionalidad revolucionaria: **modal automático**. Cuando el usuario intenta imprimir y no hay una impresora conectada, automáticamente se abre un modal para seleccionar y conectar una impresora.

#### Características del Modal Automático:
- 🔍 **Búsqueda Automática**: Escanea automáticamente las impresoras disponibles
- 🔐 **Gestión de Permisos**: Solicita permisos de Bluetooth automáticamente si es necesario
- 🎨 **UI Moderna**: Interfaz elegante con indicadores de estado
- ⚡ **Conexión Rápida**: Una vez conectada, la impresora se mantiene persistente
- 🔄 **Reconexión Automática**: Intenta reconectar si se pierde la conexión

#### Ejemplo de Implementación Completa:
```dart
class PrintingScreen extends StatelessWidget {
  final OrderData order;
  
  const PrintingScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orden #${order.number}')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Detalles de la orden
            Expanded(
              child: OrderSummary(order: order),
            ),
            
            // Botón de impresión inteligente
            SizedBox(
              width: double.infinity,
              child: SmartThermalPrintButton(
                // 🚀 Funcionalidad clave: Modal automático
                autoOpenPrinterSelection: true,
                
                // Tipos de conexión permitidos
                connectionTypes: [
                  ConnectionType.BLE,
                  ConnectionType.USB,
                  ConnectionType.NETWORK,
                ],
                
                // Generación dinámica del recibo
                generatePrintData: () => _generateOrderReceipt(order),
                
                // Configuración visual
                buttonText: 'Imprimir Orden',
                printingText: 'Imprimiendo orden...',
                icon: Icon(Icons.print),
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                
                // Mostrar impresora conectada
                showConnectedPrinter: true,
                connectedPrinterStyle: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                ),
                
                // Manejo de eventos
                onPrintCompleted: () {
                  // Mostrar éxito y navegar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Orden impresa exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                
                onPrintFailed: (error) {
                  // Mostrar error específico
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error de Impresión'),
                      content: Text('No se pudo imprimir la orden:\n$error'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                },
                
                onPrinterConnected: (printer) {
                  // Opcional: Guardar preferencia
                  _savePreferredPrinter(printer);
                },
              ),
            ),
            
            SizedBox(height: 16),
            
            // Botón de desconexión (opcional)
            DisconnectPrinterButton(
              onDisconnected: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Impresora desconectada')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<List<int>> _generateOrderReceipt(OrderData order) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    
    // Header del recibo
    bytes += generator.text(
      'RESTAURANT NAME',
      styles: PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2),
    );
    bytes += generator.text(
      'Orden #${order.number}',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text('Fecha: ${DateTime.now().toString().substring(0, 16)}');
    bytes += generator.hr();
    
    // Items de la orden
    for (var item in order.items) {
      bytes += generator.text('${item.name} x${item.quantity}');
      bytes += generator.text(
        '\$${item.total.toStringAsFixed(2)}',
        styles: PosStyles(align: PosAlign.right),
      );
    }
    
    bytes += generator.hr();
    bytes += generator.text(
      'TOTAL: \$${order.total.toStringAsFixed(2)}',
      styles: PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2),
    );
    
    bytes += generator.feed(2);
    bytes += generator.cut();
    
    return bytes;
  }
  
  void _savePreferredPrinter(Printer printer) {
    // Implementar guardado de preferencias
    // SharedPreferences, SQLite, etc.
  }
}
```

### Mejores Prácticas para el Botón Inteligente

#### ✅ Recomendaciones:

1. **Siempre usa `autoOpenPrinterSelection: true`** para la mejor experiencia de usuario
2. **Especifica los `connectionTypes`** apropiados para tu aplicación
3. **Implementa `onPrintFailed`** para manejo robusto de errores
4. **Usa `showConnectedPrinter: true`** para transparencia del usuario
5. **Para documentos grandes, usa `longData: true`**

#### ❌ Evita:

1. No proporcionar feedback al usuario (siempre usa callbacks)
2. No manejar errores de conexión
3. Usar el botón sin el modal automático en aplicaciones de producción
4. Ignorar los estados de carga (printingText es importante)

#### 🔧 Configuración Recomendada:

```dart
SmartThermalPrintButton(
  autoOpenPrinterSelection: true,    // ✅ Siempre incluir
  connectionTypes: [...],            // ✅ Especificar tipos
  showConnectedPrinter: true,        // ✅ Transparencia
  longData: true,                    // ✅ Para docs grandes
  onPrintCompleted: () => {},        // ✅ Manejo de éxito
  onPrintFailed: (error) => {},      // ✅ Manejo de errores
  onPrinterConnected: (printer) => {}, // ✅ Opcional pero útil
)
```

## 🎯 Ejemplo Completo

```dart
import 'package:flutter/material.dart';
import 'package:smart_thermal_printer_flutter/smart_thermal_printer_flutter_lib.dart';

class MyPrinterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Thermal Printer')),
      body: Column(
        children: [
          // Lista de impresoras con conexión automática
          Expanded(
            flex: 2,
            child: ThermalPrinterList(
              onPrinterConnected: (printer) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Conectado a ${printer.name}')),
                );
              },
            ),
          ),
          
          // Controles de impresión rápida
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SmartThermalPrintButton(
                    generatePrintData: _generateReceipt,
                    buttonText: 'Imprimir Recibo',
                    icon: Icon(Icons.receipt),
                  ),
                ),
                SizedBox(width: 16),
                DisconnectPrinterButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<List<int>> _generateReceipt() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    
    bytes += generator.text(
      'MI NEGOCIO',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.hr();
    bytes += generator.text('Producto: Café - \$5.00');
    bytes += generator.hr();
    bytes += generator.text(
      'Total: \$5.00',
      styles: PosStyles(bold: true),
    );
    bytes += generator.cut();
    
    return bytes;
  }
}
```

## 🔧 API Detallada

### Gestión de Conexión Persistente

```dart
final connectionManager = PrinterConnectionManager.instance;

// Conectar a una impresora
bool success = await connectionManager.connectToPrinter(printer);

// Verificar estado
bool isConnected = connectionManager.isConnected;
Printer? currentPrinter = connectionManager.connectedPrinter;

// Imprimir con conexión persistente (RÁPIDO!)
await connectionManager.print(printData);

// Desconectar
await connectionManager.disconnect();

// Escuchar cambios de estado
connectionManager.addListener(() {
  print('Estado de conexión cambió');
});
```

### Búsqueda de Impresoras

```dart
// Buscar impresoras
await smartThermalPrinter.getPrinters(
  refreshDuration: Duration(seconds: 2),
  connectionTypes: [ConnectionType.USB, ConnectionType.BLE],
  androidUsesFineLocation: true,
);

// Escuchar dispositivos encontrados
smartThermalPrinter.devicesStream.listen((printers) {
  print('Encontradas ${printers.length} impresoras');
});
```

### Impresión Tradicional

```dart
// Conectar manualmente
bool connected = await smartThermalPrinter.connect(printer);

// Imprimir
await smartThermalPrinter.printData(printer, printData);

// Desconectar
await smartThermalPrinter.disconnect(printer);
```

### Generar Contenido de Impresión

```dart
Future<List<int>> generateReceipt() async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];

  // Texto centrado y en negrita
  bytes += generator.text(
    'MI TIENDA',
    styles: PosStyles(
      align: PosAlign.center,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
      bold: true,
    ),
  );

  // Línea separadora
  bytes += generator.hr();

  // Productos
  bytes += generator.row([
    PosColumn(text: 'Producto', width: 6),
    PosColumn(text: 'Precio', width: 6, styles: PosStyles(align: PosAlign.right)),
  ]);

  bytes += generator.row([
    PosColumn(text: 'Café Premium', width: 6),
    PosColumn(text: '\$5.00', width: 6, styles: PosStyles(align: PosAlign.right)),
  ]);

  // Total
  bytes += generator.hr();
  bytes += generator.text(
    'Total: \$5.00',
    styles: PosStyles(align: PosAlign.center, bold: true),
  );

  // Espacios y corte
  bytes += generator.feed(2);
  bytes += generator.cut();

  return bytes;
}
```

## 🎨 Personalización de Widgets

### ThermalPrinterList

```dart
ThermalPrinterList(
  connectionTypes: [ConnectionType.USB, ConnectionType.BLE],
  refreshDuration: Duration(seconds: 3),
  itemDecoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: Colors.blue.shade50,
    border: Border.all(color: Colors.blue.shade200),
  ),
  connectionIconColor: Colors.purple,
  emptyText: 'No hay impresoras disponibles.\nVerifica que estén encendidas.',
  onPrinterConnected: (printer) {
    // Acción personalizada al conectar
  },
  onConnectionFailed: (error) {
    // Manejo personalizado de errores
  },
)
```

### SmartThermalPrintButton - API Completa

#### Propiedades de Datos:
```dart
SmartThermalPrintButton(
  // OPCIÓN 1: Datos pre-generados
  printData: List<int>?, // Datos de impresión en bytes
  
  // OPCIÓN 2: Generación dinámica
  generatePrintData: Future<List<int>> Function()?, // Función para generar datos
  
  // Nota: Debe especificar printData O generatePrintData, no ambos
)
```

#### Propiedades de Configuración:
```dart
SmartThermalPrintButton(
  // 🚀 NUEVA FUNCIONALIDAD: Modal automático
  autoOpenPrinterSelection: true,          // Abre modal si no hay impresora
  connectionTypes: [                       // Tipos de conexión permitidos
    ConnectionType.BLE,
    ConnectionType.USB,
    ConnectionType.NETWORK,
  ],
  
  // Configuración del botón
  buttonText: 'Imprimir',                  // Texto del botón
  printingText: 'Imprimiendo...',          // Texto durante impresión
  icon: Icon(Icons.print),                 // Icono del botón
  height: 56.0,                           // Altura del botón
  
  // Estilos personalizados
  buttonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  
  // Configuración de impresora conectada
  showConnectedPrinter: true,              // Mostrar info de impresora
  connectedPrinterStyle: TextStyle(        // Estilo del texto de impresora
    fontSize: 12,
    color: Colors.green,
    fontWeight: FontWeight.w500,
  ),
  
  // Configuración de impresión
  longData: true,                          // Para documentos grandes
)
```

#### Callbacks Disponibles:
```dart
SmartThermalPrintButton(
  // Callback de éxito
  onPrintCompleted: () {
    print('✅ Impresión completada exitosamente');
    // Lógica post-impresión
  },
  
  // Callback de error
  onPrintFailed: (String error) {
    print('❌ Error de impresión: $error');
    // Manejo de errores específicos
    showErrorDialog(error);
  },
  
  // Callback de conexión (NUEVO)
  onPrinterConnected: (Printer printer) {
    print('🔗 Conectado a: ${printer.name}');
    // Guardar preferencias, mostrar notificación, etc.
  },
)
```

#### Ejemplo Completo con Todas las Propiedades:
```dart
SmartThermalPrintButton(
  // Datos y generación
  generatePrintData: () async {
    return await generateInvoiceData();
  },
  
  // Modal automático (RECOMENDADO)
  autoOpenPrinterSelection: true,
  connectionTypes: [
    ConnectionType.BLE,
    ConnectionType.USB,
  ],
  
  // Configuración visual
  buttonText: 'Imprimir Factura',
  printingText: 'Generando factura...',
  icon: Icon(Icons.receipt_long),
  height: 64,
  
  buttonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.indigo,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 3,
  ),
  
  // Info de impresora
  showConnectedPrinter: true,
  connectedPrinterStyle: TextStyle(
    fontSize: 11,
    color: Colors.green[700],
    fontWeight: FontWeight.w600,
  ),
  
  // Configuración de impresión
  longData: true,
  
  // Callbacks completos
  onPrintCompleted: () {
    HapticFeedback.lightImpact();
    showSuccessSnackBar('Factura impresa exitosamente');
    Navigator.pop(context);
  },
  
  onPrintFailed: (error) {
    HapticFeedback.heavyImpact();
    showErrorDialog('Error al imprimir', error);
  },
  
  onPrinterConnected: (printer) {
    PreferencesService.savePreferredPrinter(printer.id);
    showInfoSnackBar('Conectado a ${printer.name}');
  },
)
```

#### Estados del Botón:

El botón maneja automáticamente diferentes estados visuales:

- **🔴 Sin Impresora**: Muestra texto normal, al presionar abre modal (si `autoOpenPrinterSelection: true`)
- **🟢 Impresora Conectada**: Muestra información de la impresora conectada
- **🟡 Imprimiendo**: Muestra `printingText` con indicador de carga
- **⚫ Deshabilitado**: Durante operaciones en segundo plano

## 🚨 Tipos de Conexión

```dart
enum ConnectionType {
  BLE,        // Bluetooth Low Energy
  USB,        // Conexión USB directa
  NETWORK,    // Conexión de red (WiFi/Ethernet)
}
```

## 🐛 Solución de Problemas

### Problemas Comunes

1. **No se encuentran impresoras Bluetooth**: 
   - Verifica que la impresora esté en modo de emparejamiento
   - Asegúrate de que los permisos de ubicación estén otorgados

2. **Conexión USB no funciona**:
   - Verifica que el cable USB esté bien conectado
   - En Windows, puede requerirse drivers específicos

3. **Impresión lenta en BLE**:
   - Usa `longData: true` para datos grandes
   - Considera dividir la impresión en partes más pequeñas

4. **La conexión se pierde**:
   - El gestor de conexión automáticamente intentará reconectar
   - Verifica la señal Bluetooth o la conexión USB

### Debug

```dart
// Habilitar logs detallados
FlutterBluePlus.setLogLevel(LogLevel.debug);

// Verificar estado de conexión
print('Conectado: ${connectionManager.isConnected}');
print('Error: ${connectionManager.connectionError}');
```

## 🔄 Migración desde flutter_thermal_printer

Si vienes del package anterior, estos son los cambios principales:

1. **Nuevo nombre del package**: `smart_thermal_printer_flutter`
2. **Nueva clase principal**: `SmartThermalPrinterFlutter` 
3. **Nuevos widgets**: `ThermalPrinterList`, `SmartThermalPrintButton`
4. **Gestión de conexión**: `PrinterConnectionManager` para conexiones persistentes
5. **Nuevo archivo de importación**: `smart_thermal_printer_flutter_lib.dart`

## 📄 Changelog

### v2.0.0
- ✨ **NUEVO**: Widgets pre-construidos para UI
- ✨ **NUEVO**: Gestión de conexión persistente
- ✨ **NUEVO**: Impresión rápida con conexión activa
- 🔄 Renombrado del package a `smart_thermal_printer_flutter`
- 🎨 Mejoras en la experiencia de usuario
- 🚀 Optimizaciones de rendimiento

## 🤝 Contribuciones

Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 📧 Soporte

Para soporte técnico o preguntas:
- 🐛 Reporta bugs en [GitHub Issues](https://github.com/jeanpaulmosqueraarevalo/smart_thermal_printer_flutter/issues)
- 💬 Preguntas en [GitHub Discussions](https://github.com/jeanpaulmosqueraarevalo/smart_thermal_printer_flutter/discussions)
- 📧 Email: jeanpaulmosqueraarevalo@example.com

---

**Smart Thermal Printer Flutter** - Haciendo la impresión térmica más inteligente y fácil 🚀

[![GitHub stars](https://img.shields.io/github/stars/jeanpaulmosqueraarevalo/smart_thermal_printer_flutter.svg?style=social&label=Star)](https://github.com/jeanpaulmosqueraarevalo/smart_thermal_printer_flutter)
[![GitHub forks](https://img.shields.io/github/forks/jeanpaulmosqueraarevalo/smart_thermal_printer_flutter.svg?style=social&label=Fork)](https://github.com/jeanpaulmosqueraarevalo/smart_thermal_printer_flutter/fork)
