import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../connection/printer_connection_manager.dart';
import '../smart_thermal_printer_flutter.dart';
import '../utils/printer.dart';
import 'printer_theme.dart';

/// Estado del Bluetooth tal como lo ve el selector.
enum _BleStatus {
  /// Todavía no sabemos (en iOS el primer valor es `unknown` mientras el
  /// sistema muestra el permiso).
  checking,
  unsupported,
  unauthorized,
  off,
  ready,
}

/// Selector de impresoras.
///
/// Es **reactivo** al Bluetooth: escucha `FlutterBluePlus.adapterState` y
/// arranca la búsqueda sola en cuanto el adaptador queda encendido. Así, la
/// primera vez en iOS (cuando el sistema pide permiso y el estado pasa de
/// `unknown` a `on`), o cuando el usuario enciende el Bluetooth con el
/// selector abierto, los dispositivos aparecen sin cerrar y volver a abrir.
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

class _PrinterSelectionModalState extends State<PrinterSelectionModal>
    with WidgetsBindingObserver {
  static const _scanWindow = Duration(seconds: 15);

  List<Printer> _printers = [];
  bool _isScanning = false;
  bool _scanFailed = false;
  String? _connectingPrinterId;
  _BleStatus _bleStatus = _BleStatus.checking;

  StreamSubscription<List<Printer>>? _devicesSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  Timer? _scanTimer;

  final PrinterConnectionManager _connectionManager =
      PrinterConnectionManager.instance;

  bool get _usesBle => widget.connectionTypes.contains(ConnectionType.BLE);

  bool get _isConnecting => _connectingPrinterId != null;

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
    WidgetsBinding.instance.addObserver(this);

    _devicesSub = SmartThermalPrinterFlutter.instance.devicesStream.listen(
      (printers) {
        if (!mounted) return;
        setState(() => _printers = List.of(printers));
      },
    );

    if (_usesBle) {
      _listenAdapter();
    } else {
      _bleStatus = _BleStatus.ready;
      _startScanning();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanTimer?.cancel();
    _adapterSub?.cancel();
    _devicesSub?.cancel();
    SmartThermalPrinterFlutter.instance.stopScan();
    super.dispose();
  }

  /// Al volver de Ajustes (permiso o Bluetooth) se reintenta si quedó listo
  /// y no hay nada en pantalla.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_bleStatus == _BleStatus.ready && !_isScanning && _printers.isEmpty) {
      _startScanning();
    }
  }

  Future<void> _listenAdapter() async {
    try {
      if (!await FlutterBluePlus.isSupported) {
        if (mounted) setState(() => _bleStatus = _BleStatus.unsupported);
        return;
      }
    } catch (_) {
      if (mounted) setState(() => _bleStatus = _BleStatus.unsupported);
      return;
    }

    // `adapterState` emite el valor actual y después cada cambio.
    _adapterSub = FlutterBluePlus.adapterState.listen(_onAdapterState);
  }

  void _onAdapterState(BluetoothAdapterState state) {
    if (!mounted) return;
    final previous = _bleStatus;
    final next = switch (state) {
      BluetoothAdapterState.on => _BleStatus.ready,
      BluetoothAdapterState.unauthorized => _BleStatus.unauthorized,
      BluetoothAdapterState.unavailable => _BleStatus.unsupported,
      BluetoothAdapterState.off ||
      BluetoothAdapterState.turningOff =>
        _BleStatus.off,
      // `unknown` / `turningOn`: esperando al sistema.
      _ => _BleStatus.checking,
    };
    if (next == previous) return;

    setState(() => _bleStatus = next);

    if (next == _BleStatus.ready) {
      _startScanning();
    } else if (previous == _BleStatus.ready) {
      // Se apagó o se revocó con el selector abierto: se limpia la lista
      // (las BLE ya no son alcanzables) y se para la búsqueda.
      _stopScanning();
      setState(() {
        _printers = _printers
            .where((p) => p.connectionType != ConnectionType.BLE)
            .toList();
      });
    }
  }

  Future<void> _turnOnBluetooth() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (_) {
        // El usuario rechazó el diálogo del sistema: seguimos esperando.
      }
    }
    // En iOS no hay API para encenderlo: el texto guía al usuario y el
    // listener del adaptador arranca la búsqueda cuando lo active.
  }

  /// Empezar (o reiniciar) la búsqueda.
  Future<void> _startScanning() async {
    if (_usesBle && _bleStatus != _BleStatus.ready) return;
    _scanTimer?.cancel();
    setState(() {
      _isScanning = true;
      _scanFailed = false;
    });

    try {
      await SmartThermalPrinterFlutter.instance.getPrinters(
        refreshDuration: const Duration(seconds: 2),
        connectionTypes: widget.connectionTypes,
        androidUsesFineLocation: true,
      );
      _scanTimer = Timer(_scanWindow, _stopScanning);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _scanFailed = true;
      });
    }
  }

  void _stopScanning() {
    _scanTimer?.cancel();
    SmartThermalPrinterFlutter.instance.stopScan();
    if (mounted && _isScanning) setState(() => _isScanning = false);
  }

  /// Conectar a una impresora
  Future<void> _connectToPrinter(Printer printer) async {
    setState(() => _connectingPrinterId = printer.address);

    try {
      final success = await _connectionManager.connectToPrinter(printer);

      if (success) {
        await Future.delayed(const Duration(milliseconds: 300));
        widget.onPrinterConnected?.call(printer);

        if (mounted) {
          showPrinterSnackBar(
            context,
            _s.connectedTo(printer.name ?? _s.unnamedPrinter),
            color: (t) => t.success,
            icon: Icons.check_circle_rounded,
            duration: const Duration(seconds: 1),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop(printer);
          }
        }
      } else {
        final error = _connectionManager.connectionError ?? _s.connectionError;
        widget.onConnectionFailed?.call(error);
        if (mounted) {
          showPrinterSnackBar(
            context,
            _s.connectFailed(error),
            color: (t) => t.danger,
            icon: Icons.error_rounded,
          );
        }
      }
    } catch (e) {
      widget.onConnectionFailed?.call(e.toString());
      if (mounted) {
        showPrinterSnackBar(
          context,
          _s.connectionErrorDetail('$e'),
          color: (t) => t.danger,
          icon: Icons.error_rounded,
        );
      }
    } finally {
      if (mounted) setState(() => _connectingPrinterId = null);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = PrinterTheme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * .75;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight.clamp(320, 560)),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(t),
            _buildHeader(t),
            SizedBox(
              height: 2,
              child: _isScanning
                  ? LinearProgressIndicator(
                      minHeight: 2,
                      color: t.primary,
                      backgroundColor: t.soft(t.primary),
                    )
                  : null,
            ),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _buildBody(t),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: t.textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _s.cancel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(PrinterTheme t) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: t.textMuted.withValues(alpha: .35),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(PrinterTheme t) {
    final canRefresh =
        !_isScanning && (!_usesBle || _bleStatus == _BleStatus.ready);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 14),
      child: Row(
        children: [
          _IconBubble(icon: Icons.print_rounded, color: t.primary, t: t),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _s.selectPrinterTitle,
                  style: TextStyle(
                    color: t.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _headerSubtitle,
                  style: TextStyle(color: t.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: canRefresh ? _startScanning : null,
            tooltip: _s.searchAgain,
            icon: Icon(
              Icons.refresh_rounded,
              color: canRefresh ? t.primary : t.textMuted.withValues(alpha: .4),
            ),
          ),
        ],
      ),
    );
  }

  String get _headerSubtitle {
    if (_usesBle && _bleStatus != _BleStatus.ready) {
      return _s.bluetoothUnavailable;
    }
    if (_isScanning) {
      return _printers.isEmpty
          ? _s.searchingNearby
          : _s.searchingFound(_printers.length);
    }
    if (_printers.isEmpty) return _s.noResults;
    return _s.found(_printers.length);
  }

  Widget _buildBody(PrinterTheme t) {
    if (_usesBle && _bleStatus != _BleStatus.ready) {
      return _buildBleState(t);
    }
    if (_printers.isEmpty) {
      return _isScanning
          ? _EmptyState(
              key: const ValueKey('scanning'),
              t: t,
              icon: Icons.bluetooth_searching_rounded,
              color: t.primary,
              title: _s.searchingPrintersTitle,
              message: _s.searchingPrintersMessage,
              loading: true,
            )
          : _EmptyState(
              key: const ValueKey('empty'),
              t: t,
              icon: _scanFailed
                  ? Icons.error_outline_rounded
                  : Icons.print_disabled_rounded,
              color: _scanFailed ? t.danger : t.textMuted,
              title: _scanFailed ? _s.scanFailedTitle : _s.noPrintersFound,
              message: _s.noPrintersMessage,
              actionLabel: _s.searchAgain,
              actionIcon: Icons.search_rounded,
              onAction: _startScanning,
            );
    }

    return ListView.separated(
      key: const ValueKey('list'),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      itemCount: _printers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildPrinterTile(t, _printers[index]),
    );
  }

  Widget _buildBleState(PrinterTheme t) {
    final isIOS = !kIsWeb && Platform.isIOS;
    switch (_bleStatus) {
      case _BleStatus.off:
        return _EmptyState(
          key: const ValueKey('off'),
          t: t,
          icon: Icons.bluetooth_disabled_rounded,
          color: t.warning,
          title: _s.bluetoothOffTitle,
          message: isIOS ? _s.bluetoothOffMessageIOS : _s.bluetoothOffMessage,
          actionLabel: isIOS ? null : _s.turnOnBluetooth,
          actionIcon: Icons.bluetooth_rounded,
          onAction: isIOS ? null : _turnOnBluetooth,
        );
      case _BleStatus.unauthorized:
        return _EmptyState(
          key: const ValueKey('unauthorized'),
          t: t,
          icon: Icons.lock_outline_rounded,
          color: t.warning,
          title: _s.bluetoothPermissionTitle,
          message: isIOS
              ? _s.bluetoothPermissionMessageIOS
              : _s.bluetoothPermissionMessage,
        );
      case _BleStatus.unsupported:
        return _EmptyState(
          key: const ValueKey('unsupported'),
          t: t,
          icon: Icons.bluetooth_disabled_rounded,
          color: t.danger,
          title: _s.bluetoothUnavailable,
          message: _s.bluetoothUnsupportedMessage,
        );
      case _BleStatus.checking:
      case _BleStatus.ready:
        return _EmptyState(
          key: const ValueKey('checking'),
          t: t,
          icon: Icons.bluetooth_rounded,
          color: t.primary,
          title: _s.preparingBluetoothTitle,
          message: _s.preparingBluetoothMessage,
          loading: true,
        );
    }
  }

  Widget _buildPrinterTile(PrinterTheme t, Printer printer) {
    final isConnecting = _connectingPrinterId == printer.address;
    final isCurrent = _connectionManager.isConnected &&
        _connectionManager.connectedPrinter?.address == printer.address;
    final (IconData icon, Color color) = switch (printer.connectionType) {
      ConnectionType.BLE => (Icons.bluetooth_rounded, t.primary),
      ConnectionType.USB => (Icons.usb_rounded, t.warning),
      ConnectionType.NETWORK => (Icons.wifi_rounded, t.success),
      _ => (Icons.print_rounded, t.textMuted),
    };

    return Material(
      color: t.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _isConnecting ? null : () => _connectToPrinter(printer),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent ? t.success : t.border,
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _IconBubble(icon: icon, color: color, t: t, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      printer.name ?? _s.unnamedPrinter,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: t.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        printer.connectionType?.name ??
                            _s.unknownConnectionType,
                        if (printer.address != null) printer.address!,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: t.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isConnecting)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: t.primary,
                  ),
                )
              else if (isCurrent)
                _Pill(label: _s.connectedPill, color: t.success, t: t)
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: _isConnecting
                      ? t.textMuted.withValues(alpha: .3)
                      : t.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.color,
    required this.t,
    this.size = 44,
  });

  final IconData icon;
  final Color color;
  final PrinterTheme t;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.soft(color),
        borderRadius: BorderRadius.circular(size * .32),
      ),
      child: Icon(icon, color: color, size: size * .52),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, required this.t});

  final String label;
  final Color color;
  final PrinterTheme t;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: t.soft(color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    super.key,
    required this.t,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.loading = false,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final PrinterTheme t;
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final bool loading;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: t.soft(color),
                    shape: BoxShape.circle,
                  ),
                ),
                if (loading)
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color.withValues(alpha: .6),
                    ),
                  ),
                Icon(icon, size: 34, color: color),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.textMuted, fontSize: 13.5, height: 1.35),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon ?? Icons.search_rounded, size: 20),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                backgroundColor: t.primary,
                foregroundColor: t.onPrimary,
                minimumSize: const Size(0, 46),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
