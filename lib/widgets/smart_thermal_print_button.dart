import 'package:flutter/material.dart';

import '../connection/printer_connection_manager.dart';
import '../utils/printer.dart';
import '../connection/print_error_messages.dart';
import 'print_progress_dialog.dart';
import 'printer_selection_modal.dart';
import 'printer_theme.dart';

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

  //icoNColor
  final Color? iconColor;

  /// Identifica el comprobante (p. ej. id del pago) para detectar
  /// reimpresiones. Sin él se usa la huella de los bytes, que cambia si el
  /// ticket lleva la hora de impresión.
  final String? printKey;

  /// Pedir confirmación si el mismo comprobante ya se imprimió hace poco.
  final bool confirmReprint;

  /// Mostrar el diálogo animado teléfono → impresora mientras imprime. En
  /// `false` se mantiene el comportamiento anterior (SnackBars).
  final bool showPrintAnimation;

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
    this.iconColor,
    this.printKey,
    this.confirmReprint = true,
    this.showPrintAnimation = true,
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
        showPrinterSnackBar(
          context,
          'Esperando reconexión, intente nuevamente...',
          color: (t) => t.warning,
          icon: Icons.info_rounded,
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
            showPrinterSnackBar(
              context,
              'No se pudo conectar a la impresora',
              color: (t) => t.warning,
              icon: Icons.info_rounded,
            );
          }
          return; // El usuario canceló o no se conectó
        }
        // Si se conectó, continuar con la impresión automáticamente
      } else {
        // Comportamiento original: mostrar error
        widget.onPrintFailed?.call('No hay impresora conectada');
        if (mounted) {
          showPrinterSnackBar(
            context,
            'No hay impresora conectada',
            color: (t) => t.danger,
            icon: Icons.error_rounded,
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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: PrinterTheme.of(context).sheet,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
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
    // Otro botón (u otro toque) ya está imprimiendo: no se encola nada.
    if (_isPrinting || _connectionManager.isPrinting) {
      _notifyError(describePrintError('Ya hay una impresión en curso'));
      return;
    }
    // Verificar nuevamente la conexión antes de imprimir
    if (!_connectionManager.isConnected) {
      _notifyError(describePrintError('No hay impresora conectada'));
      return;
    }

    setState(() => _isPrinting = true);
    try {
      List<int> data;
      try {
        data = widget.printData ?? await widget.generatePrintData!();
      } catch (e) {
        debugPrint('Error generando el comprobante: $e');
        _notifyError(
          const PrintErrorInfo(
            'No se pudo armar el comprobante',
            'Vuelve a abrirlo e intenta de nuevo.',
          ),
        );
        return;
      }
      if (data.isEmpty) {
        _notifyError(describePrintError('No hay datos para imprimir'));
        return;
      }

      final key = widget.printKey ?? PrinterConnectionManager.fingerprint(data);
      if (widget.confirmReprint && !await _confirmReprintIfNeeded(key)) {
        return;
      }

      // Bucle de reintento: lo decide el usuario desde el diálogo, nunca
      // automático (un reintento a ciegas puede duplicar el comprobante).
      while (mounted) {
        final retry = await _printOnce(data, key);
        if (!retry) break;
        if (!_connectionManager.isConnected) {
          _notifyError(describePrintError('No hay impresora conectada'));
          break;
        }
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  /// Un intento de impresión. Devuelve `true` si el usuario pidió reintentar.
  Future<bool> _printOnce(List<int> data, String key) async {
    ValueNotifier<PrintProgress>? progress;
    Future<PrintDialogResult?>? dialog;
    if (widget.showPrintAnimation && mounted) {
      progress = ValueNotifier(PrintProgress(
        PrintPhase.sending,
        printerName: _connectionManager.connectedPrinter?.name,
      ));
      dialog = showPrintProgressDialog(context, progress);
    }

    debugPrint('Iniciando impresión con ${data.length} bytes de datos');
    final success = await _connectionManager.print(
      data,
      longData: widget.longData,
      key: key,
    );

    if (success) {
      progress?.value = PrintProgress(
        PrintPhase.verifying,
        printerName: _connectionManager.connectedPrinter?.name,
      );
      // Realizar disconnect y reconnect para verificar errores de la impresora
      await _performDisconnectReconnect();
      widget.onPrintCompleted?.call();
      if (progress != null) {
        progress.value = const PrintProgress(PrintPhase.success);
        await dialog;
        progress.dispose();
      } else if (mounted) {
        showPrinterSnackBar(
          context,
          'Impresión completada exitosamente',
          color: (t) => t.success,
          icon: Icons.check_circle_rounded,
        );
      }
      return false;
    }

    final info = _connectionManager.lastPrintError ??
        describePrintError(_connectionManager.connectionError ?? '');
    widget.onPrintFailed?.call(info.message);
    if (progress != null) {
      progress.value = PrintProgress(PrintPhase.error, error: info);
      final result = await dialog;
      progress.dispose();
      return result == PrintDialogResult.retry;
    }
    _notifyError(info, callback: false);
    return false;
  }

  /// Si el comprobante ya salió hace poco, preguntar antes de otra copia.
  Future<bool> _confirmReprintIfNeeded(String key) async {
    final at = _connectionManager.lastPrintedAt(key);
    if (at == null || !mounted) return true;
    final minutes = DateTime.now().difference(at).inMinutes;
    final when = minutes < 1
        ? 'hace un momento'
        : 'hace $minutes ${minutes == 1 ? 'minuto' : 'minutos'}';
    final t = PrinterTheme.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.sheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.content_copy_rounded, color: t.warning, size: 30),
        title: Text(
          '¿Imprimir otra copia?',
          style: TextStyle(color: t.text, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Este comprobante ya se imprimió $when.',
          textAlign: TextAlign.center,
          style: TextStyle(color: t.textMuted, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(foregroundColor: t.textMuted),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: t.primary,
              foregroundColor: t.onPrimary,
            ),
            child: const Text('Imprimir copia'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  void _notifyError(
    PrintErrorInfo info, {
    bool callback = true,
  }) {
    if (callback) widget.onPrintFailed?.call(info.message);
    if (!mounted) return;
    showPrinterSnackBar(
      context,
      info.message,
      color: (t) => t.danger,
      icon: Icons.error_rounded,
      duration: const Duration(seconds: 5),
    );
  }

  /// Realizar desconexión y reconexión para verificar errores de la impresora
  Future<void> _performDisconnectReconnect() async {
    final currentPrinter = _connectionManager.connectedPrinter;
    if (currentPrinter == null) return;

    try {
      debugPrint(
          'Realizando disconnect/reconnect para verificar errores de impresora');

      // Desconectar
      await _connectionManager.disconnect();

      // Esperar un momento antes de reconectar
      await Future.delayed(const Duration(milliseconds: 500));

      // Reconectar
      final reconnected =
          await _connectionManager.connectToPrinter(currentPrinter);

      if (!reconnected) {
        debugPrint(
            'Advertencia: No se pudo reconectar después de la impresión');
        if (mounted) {
          showPrinterSnackBar(
            context,
            'Advertencia: Reconexión falló después de impresión',
            color: (t) => t.warning,
            icon: Icons.info_rounded,
          );
        }
      } else {
        debugPrint('Reconexión exitosa después de la impresión');
      }
    } catch (e) {
      debugPrint('Error durante disconnect/reconnect: $e');
      // No mostramos error aquí ya que la impresión fue exitosa
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
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.iconColor ?? Colors.white,
        ),
      );
    }

    if (isConnected) {
      return widget.icon != null
          ? widget.icon!
          : (widget.iconColor == null
              ? const Icon(Icons.print)
              : Icon(Icons.print, color: widget.iconColor));
    } else {
      return widget.iconColor == null
          ? const Icon(Icons.settings_bluetooth)
          : Icon(Icons.settings_bluetooth, color: widget.iconColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PrinterTheme.of(context);
    final isConnected = _connectionManager.isConnected;
    final connectedPrinter = _connectionManager.connectedPrinter;
    final reconnecting = _connectionManager.isReconnecting;
    final statusColor = reconnecting ? t.warning : t.success;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Impresora conectada: chip de estado + desconectar.
        if (widget.showConnectedPrinter &&
            isConnected &&
            connectedPrinter != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: t.soft(statusColor),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: .35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (reconnecting)
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: statusColor,
                            ),
                          )
                        else
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: statusColor,
                          ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            reconnecting
                                ? 'Reconectando...'
                                : 'Conectado: ${connectedPrinter.name ?? 'Impresora'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!reconnecting) ...[
                  const SizedBox(width: 6),
                  DisconnectPrinterButton(
                    size: 34,
                    onDisconnected: () {},
                  ),
                ],
              ],
            ),
          ),

        // Botón de impresión
        Row(
          children: [
            SizedBox(
              height: widget.height ?? 50,
              child: ElevatedButton.icon(
                onPressed:
                    (!_isPrinting && !reconnecting) ? _handlePrint : null,
                style: widget.buttonStyle ??
                    ElevatedButton.styleFrom(
                      backgroundColor: reconnecting || !isConnected
                          ? t.fill(t.warning)
                          : t.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                icon: _isPrinting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.iconColor ?? Colors.white,
                        ),
                      )
                    : _getButtonIcon(isConnected),
                label: Text(
                  _getButtonText(isConnected),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
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
      showPrinterSnackBar(
        context,
        'Impresora desconectada',
        color: (t) => t.warning,
        icon: Icons.info_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_connectionManager.isConnected) {
      return const SizedBox.shrink();
    }

    final t = PrinterTheme.of(context);
    final color = widget.color ?? t.danger;
    return IconButton(
      onPressed: _handleDisconnect,
      icon: Icon(
        Icons.link_off_rounded,
        size: widget.size * 0.52,
        color: color,
      ),
      style: IconButton.styleFrom(
        backgroundColor: t.soft(color),
        fixedSize: Size(widget.size, widget.size),
        minimumSize: Size(widget.size, widget.size),
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
      ),
      tooltip: 'Desconectar impresora',
    );
  }
}
