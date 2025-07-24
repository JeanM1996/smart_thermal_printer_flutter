## 1.1.0
* Added Improvments for windows Printing Thanks to `@eduardohr-muniz`
* Updated Dependents Packages

## 1.0.1
* Updated ReadMe

## 1.0.0
* New Feature Network Printers added 
* Thanks to `@eduardohr-muniz`

## 0.0.20
* Bugs fixed for usb printers

## 0.0.19+2
* Bugs fixed for usb printers

## 0.0.19+1
* Bugs Fixes

## 0.0.19
* Refracted code and fixed bugs

## 0.0.18+1
* Update some bugs

## 0.0.18
* Added `turnOnBluetooth` function
* Added `isBleTurnedOnStream` Stream of bluetooth is turned on or off
* Added `isBleTurnedOn` function
* Added `printWidget` function for printing any flutter widget
* Updated USB Connection for Android
* Updated BLE for All Platforms

## 0.0.17
* Fixed get system devices in ble

## 0.0.16
* Bumped packages dependent on like flutter_blue_plus,win32,flutter_utils_plus

## 0.0.15
* Added new extension for Printer of connectionsState
* Now you can get system connected devices on macos

## 0.0.14
* Fixed flickering of bt devices
* Added some improvements

## 0.0.13
* Removed unused library flutterlib_serialport
* Updated some dependencies

## 0.0.12
* Some Bugs Fixed in MacOs

## 0.0.11
* Some Bugs Fixed in MacOs

## 0.0.10
* Some Bugs Fixed in MacOs

## 0.0.9
* Added Getting USB Devices for MacOs

## 0.0.8
* Updated Bluetooth Services Package

## 0.0.7
* Removed test printing from the example

## 0.0.6
* Added USB Printing for Windows Devices
* Read Take Care Of part at below in Readme for More.

## 0.0.5
* Added esc_pos_utils_plus for printing 

## 0.0.4
* Added getPrinter() to get the printers from both USB and Bluetooth

## 0.0.3
* Added USB Printer Support for Android 

## 0.0.2

* Added Support for Windows Bluetooth
* Added Start and Stop Scanning for BLE devices
* Added Connect and Disconnect Printer
* Added Printer Model Class
* Added `longdata` to print data for long text

## 0.0.1

# Changelog

## [2.0.0] - 2025-01-24

### 🎉 Características Principales (NUEVAS)

- ✨ **Widget ThermalPrinterList**: Lista automática de impresoras disponibles con conexión directa
- ✨ **Widget SmartThermalPrintButton**: Botón inteligente para impresión rápida 
- ✨ **Widget DisconnectPrinterButton**: Botón compacto para desconectar impresora
- ✨ **PrinterConnectionManager**: Gestor de conexiones persistentes para impresión rápida
- ✨ **Conexión Persistente**: Mantiene la conexión activa para evitar retrasos
- ✨ **Monitoreo Automático**: Verificación automática del estado de conexión

### 🔄 Cambios Importantes

- 📦 **Nuevo nombre**: Migrado de `flutter_thermal_printer` a `smart_thermal_printer_flutter`
- 🏗️ **Nueva arquitectura**: Clase principal renombrada a `SmartThermalPrinterFlutter`
- 📁 **Nuevo archivo de entrada**: `smart_thermal_printer_flutter_lib.dart` para importaciones simplificadas
- 🎯 **API mejorada**: Interfaces más intuitivas y fáciles de usar

### 🚀 Mejoras de Rendimiento

- ⚡ **Impresión más rápida**: Con conexiones persistentes, la impresión es inmediata
- 🔧 **Gestión automática**: El sistema maneja automáticamente reconexiones y errores
- 📱 **Mejor UX**: Widgets pre-construidos para una implementación más rápida

### 🎨 Nuevos Widgets UI

#### ThermalPrinterList
- Lista automática de impresoras disponibles
- Conexión con un solo toque
- Indicadores visuales de estado
- Personalización completa de apariencia

#### SmartThermalPrintButton  
- Impresión con un solo botón
- Indicador de impresora conectada
- Estados de loading y error
- Soporte para datos dinámicos y estáticos

#### DisconnectPrinterButton
- Botón compacto para desconectar
- Aparece solo cuando hay conexión activa
- Personalizable en tamaño y color

### 📚 Documentación

- 📖 **README completamente reescrito** con ejemplos detallados
- 🎯 **Guías de migración** desde la versión anterior
- 💡 **Ejemplos prácticos** para todos los nuevos widgets
- 🔧 **Guía de solución de problemas** expandida

### 🔧 Compatibilidad

- ✅ Mantiene compatibilidad con la API anterior
- ✅ Soporte completo para todas las plataformas existentes
- ✅ Mismos tipos de conexión: USB, BLE, Network

### 📦 Dependencias

- ⬆️ Actualizadas todas las dependencias a las últimas versiones
- 🔄 Mantenimiento de compatibilidad con Flutter SDK >= 3.3.0

---

## [1.1.0] - Versión anterior

### Características base
- Soporte para impresión en múltiples plataformas
- Conexión USB, Bluetooth y Red
- Comandos ESC/POS
- Impresión de texto e imágenes

---

### 🎯 Próximas versiones

#### [2.1.0] - Planificado
- 🖼️ **Widget de vista previa** de impresión
- 📊 **Plantillas predefinidas** para recibos comunes
- 🔄 **Auto-reconexión mejorada** con configuración personalizable
- 📱 **Soporte para tablets** con diseños adaptativos

#### [2.2.0] - Planificado  
- 🎨 **Temas personalizables** para todos los widgets
- 📈 **Analytics de impresión** (contadores, estadísticas)
- 🔐 **Seguridad mejorada** para conexiones de red
- 🌐 **Internacionalización** completa

---

### 📋 Guía de Migración v1.x → v2.0

#### Cambios de importación
```dart
// Antes (v1.x)
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';

// Ahora (v2.0)
import 'package:smart_thermal_printer_flutter/smart_thermal_printer_flutter_lib.dart';
```

#### Cambios de instancia
```dart
// Antes (v1.x)
final printer = FlutterThermalPrinter.instance;

// Ahora (v2.0) - Funciona igual
final printer = SmartThermalPrinterFlutter.instance;

// NUEVO (v2.0) - Gestión de conexión persistente
final connectionManager = PrinterConnectionManager.instance;
```

#### Implementación simplificada
```dart
// Antes (v1.x) - Proceso manual completo
await printer.getPrinters();
printer.devicesStream.listen((devices) {
  // Mostrar lista manualmente
});
await printer.connect(selectedPrinter);
await printer.printData(selectedPrinter, data);

// Ahora (v2.0) - Con widgets automáticos
Widget build(BuildContext context) {
  return Column(
    children: [
      ThermalPrinterList(), // Lista automática con conexión
      SmartThermalPrintButton( // Botón automático de impresión
        generatePrintData: () => myPrintData,
      ),
    ],
  );
}
```

### ⚠️ Cambios que requieren actualización

1. **Nombre del package**: Actualizar en `pubspec.yaml`
2. **Imports**: Cambiar a la nueva ruta de importación  
3. **Clase principal**: Opcional - `SmartThermalPrinterFlutter` vs `FlutterThermalPrinter`

### ✅ Mantiene compatibilidad

- Todos los métodos existentes funcionan igual
- Mismos tipos de datos y enums
- Misma funcionalidad core de impresión
- No hay cambios breaking en la API principal
