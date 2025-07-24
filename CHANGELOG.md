# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-24

### 🚀 NUEVA FUNCIONALIDAD PRINCIPAL: Modal Automático de Selección

#### Agregado
- **🎯 Modal Automático**: El `SmartThermalPrintButton` ahora abre automáticamente un modal de selección de impresoras cuando no hay ninguna conectada
- **🔐 Gestión Automática de Permisos**: Solicita permisos de Bluetooth automáticamente cuando es necesario
- **📱 UI Moderna**: Modal con diseño elegante y indicadores de estado en tiempo real
- **⚡ Conexión Inteligente**: Reconexión automática y gestión de estados de conexión
- **🎨 Widgets Completamente Nuevos**:
  - `PrinterSelectionModal`: Modal contextual para selección de impresoras
  - `SmartThermalPrintButton`: Botón inteligente con modal automático
  - `ThermalPrinterList`: Lista de impresoras con conexión automática
  - `DisconnectPrinterButton`: Botón compacto para desconexión

#### Nuevas Propiedades del SmartThermalPrintButton
- `autoOpenPrinterSelection`: Habilita el modal automático (RECOMENDADO: true)
- `connectionTypes`: Especifica tipos de conexión permitidos [BLE, USB, NETWORK]
- `onPrinterConnected`: Callback cuando se conecta una impresora desde el modal
- `showConnectedPrinter`: Muestra información de la impresora conectada
- `connectedPrinterStyle`: Personalización del estilo del texto de impresora
- `longData`: Optimización para documentos grandes

#### Gestión de Conexión Persistente
- **PrinterConnectionManager**: Singleton para gestión de conexiones persistentes
- **Monitoreo Automático**: Detección automática de desconexiones y reconexión
- **Estado en Tiempo Real**: Listeners para cambios de estado de conexión
- **Impresión Rápida**: Conexión mantenida para impresión inmediata

### 🔄 Cambios de Ruptura (Breaking Changes)



- **API Mejorada**: Algunos métodos han sido refactorizados para mejor consistencia

### ✨ Mejoras
- **Documentación Completa**: README expandido con ejemplos detallados y mejores prácticas
- **Ejemplos Avanzados**: Casos de uso reales con generación dinámica de recibos
- **Manejo Robusto de Errores**: Sistema mejorado de manejo de errores y callbacks
- **UI/UX Mejorada**: Componentes visuales más modernos y responsivos
- **Rendimiento**: Optimizaciones para conexiones BLE y documentos grandes

### 🐛 Correcciones
- Resueltos problemas de compilación después del renombrado
- Corregidas advertencias de APIs deprecadas (`withOpacity`)
- Eliminadas importaciones no utilizadas
- Arreglados problemas de referencias en archivos de test

### 📚 Documentación
- **README Completamente Renovado**: 
  - Ejemplos paso a paso del modal automático
  - Guía de mejores prácticas
  - API completa documentada
  - Casos de uso avanzados
- **Ejemplos de Implementación**: Código completo para diferentes escenarios
- **Guía de Migración**: Instrucciones para actualizar desde v1.x

### 🔧 Mejores Prácticas Recomendadas
```dart
// Configuración recomendada para producción
SmartThermalPrintButton(
  autoOpenPrinterSelection: true,     // ✅ Modal automático
  connectionTypes: [ConnectionType.BLE, ConnectionType.USB],
  showConnectedPrinter: true,         // ✅ Transparencia para el usuario
  longData: true,                     // ✅ Para documentos grandes
  onPrintCompleted: () => {},         // ✅ Manejo de éxito
  onPrintFailed: (error) => {},       // ✅ Manejo de errores
  onPrinterConnected: (printer) => {}, // ✅ Callback de conexión
)
```

### 🎯 Experiencia de Usuario Mejorada
- **Un Solo Clic**: El usuario solo necesita presionar "Imprimir" - todo lo demás es automático
- **Sin Configuración Manual**: No más pasos manuales para conectar impresoras
- **Feedback Visual**: Estados claros de conexión, impresión y errores
- **Persistencia**: Las conexiones se mantienen entre impresiones

---

## [1.0.0] - Versión Legacy

### Funcionalidades Base (Heredadas)
- Soporte básico para impresión térmica
- Conexiones USB, Bluetooth y Red
- Comandos ESC/POS
- Soporte multiplataforma (Android, iOS, Windows, macOS)

---

## Guía de Migración de v1.x a v2.0

### 1. Actualizar Dependencia
```yaml
dependencies:
  smart_thermal_printer_flutter: ^2.0.0  # Nuevo nombre
```

### 2. Actualizar Imports
```dart
// Antes (v1.x)


// Después (v2.0)
import 'package:smart_thermal_printer_flutter/smart_thermal_printer_flutter_lib.dart';
```

### 3. Actualizar Clase Principal
```dart
// Antes (v1.x)
final printer = FlutterThermalPrinter.instance;

// Después (v2.0)
final printer = SmartThermalPrinterFlutter.instance;
```

### 4. Usar Nuevos Widgets (Recomendado)
```dart
// Reemplazar implementación manual con widgets inteligentes
SmartThermalPrintButton(
  autoOpenPrinterSelection: true,
  generatePrintData: () => generateMyReceipt(),
  // ... otras propiedades
)
```

### 5. Aprovechar Conexión Persistente
```dart
// Usar el nuevo manager de conexiones
final connectionManager = PrinterConnectionManager.instance;
bool isConnected = connectionManager.isConnected;
```

Para más detalles, consulta la documentación completa en el README.md
