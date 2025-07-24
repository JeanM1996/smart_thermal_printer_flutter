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

### SmartThermalPrintButton

```dart
SmartThermalPrintButton(
  printData: myPrintData, // O usar generatePrintData
  buttonText: 'Imprimir Factura',
  printingText: 'Procesando...',
  buttonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  icon: Icon(Icons.print),
  longData: true, // Para datos grandes
  showConnectedPrinter: true, // Mostrar nombre de impresora
  height: 60, // Altura personalizada
  onPrintCompleted: () {
    print('¡Impresión exitosa!');
  },
  onPrintFailed: (error) {
    print('Error: $error');
  },
)
```

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
