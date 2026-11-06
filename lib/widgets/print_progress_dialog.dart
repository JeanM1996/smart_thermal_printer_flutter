import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../connection/print_error_messages.dart';
import 'printer_theme.dart';

/// Fase visible de una impresión.
enum PrintPhase { sending, verifying, success, error }

/// Estado que el botón empuja al diálogo mientras imprime.
class PrintProgress {
  const PrintProgress(this.phase, {this.error, this.printerName});

  final PrintPhase phase;
  final PrintErrorInfo? error;
  final String? printerName;
}

/// Resultado del diálogo de progreso.
enum PrintDialogResult { done, retry }

/// Muestra el diálogo con la animación teléfono → impresora. Lo cierra el
/// propio diálogo: solo en éxito (tras un instante) o por acción del usuario
/// en error. Mientras se envía no se puede cerrar, para no tocar imprimir
/// dos veces.
Future<PrintDialogResult?> showPrintProgressDialog(
  BuildContext context,
  ValueNotifier<PrintProgress> progress,
) {
  return showDialog<PrintDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: _PrintProgressDialog(progress: progress),
    ),
  );
}

class _PrintProgressDialog extends StatefulWidget {
  const _PrintProgressDialog({required this.progress});

  final ValueNotifier<PrintProgress> progress;

  @override
  State<_PrintProgressDialog> createState() => _PrintProgressDialogState();
}

class _PrintProgressDialogState extends State<_PrintProgressDialog>
    with TickerProviderStateMixin {
  /// Ciclo del envío: el comprobante sale del teléfono, viaja y se imprime.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  /// Remate: éxito (papel completo + check) o error (sacudida).
  late final AnimationController _finish = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  PrintPhase _phase = PrintPhase.sending;

  @override
  void initState() {
    super.initState();
    widget.progress.addListener(_onProgress);
    _onProgress();
  }

  void _onProgress() {
    final p = widget.progress.value;
    if (p.phase == _phase && p.phase != PrintPhase.sending) return;
    setState(() => _phase = p.phase);
    switch (p.phase) {
      case PrintPhase.sending:
      case PrintPhase.verifying:
        if (!_loop.isAnimating) _loop.repeat();
        _finish.reset();
      case PrintPhase.success:
        _loop.stop();
        _finish.forward(from: 0);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.of(context).pop(PrintDialogResult.done);
        });
      case PrintPhase.error:
        _loop.stop();
        _finish.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.progress.removeListener(_onProgress);
    _loop.dispose();
    _finish.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = PrinterTheme.of(context);
    final p = widget.progress.value;
    final error = p.error;
    final isError = _phase == PrintPhase.error;

    final title = switch (_phase) {
      PrintPhase.sending => 'Enviando a la impresora',
      PrintPhase.verifying => 'Imprimiendo comprobante',
      PrintPhase.success => '¡Comprobante impreso!',
      PrintPhase.error => error?.title ?? 'No se pudo imprimir',
    };
    final subtitle = switch (_phase) {
      PrintPhase.sending ||
      PrintPhase.verifying =>
        p.printerName == null ? 'No cierres esta pantalla' : p.printerName!,
      PrintPhase.success => 'Retira el papel de la impresora',
      PrintPhase.error => error?.hint ?? 'Intenta de nuevo.',
    };
    final accent = switch (_phase) {
      PrintPhase.success => t.success,
      PrintPhase.error => t.danger,
      _ => t.primary,
    };

    return Dialog(
      backgroundColor: t.sheet,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 168,
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_loop, _finish]),
                  builder: (context, _) => CustomPaint(
                    painter: _PhoneToPrinterPainter(
                      t: t,
                      loop: _loop.value,
                      finish: Curves.easeOutBack
                          .transform(_finish.value.clamp(0, 1)),
                      phase: _phase,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  title,
                  key: ValueKey(title),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isError ? accent : t.text,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 14, height: 1.35, color: t.textMuted),
              ),
              if (isError && (error?.mayHavePrinted ?? false)) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: t.soft(t.warning),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: 18, color: t.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Si el papel ya salió completo, no reimprimas.',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: t.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isError) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(PrintDialogResult.done),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: t.text,
                          side: BorderSide(color: t.border),
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pop(PrintDialogResult.retry),
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: const Text('Reintentar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: t.primary,
                          foregroundColor: t.onPrimary,
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else
                const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Escena: teléfono a la izquierda, impresora a la derecha.
///
/// Ciclo de envío (`loop` 0→1):
///  0.00–0.30  el comprobante se arma en la pantalla y sale por arriba
///  0.30–0.62  vuela en arco hasta la impresora (estela de puntos)
///  0.62–1.00  el papel sale de la ranura con las líneas impresas
class _PhoneToPrinterPainter extends CustomPainter {
  _PhoneToPrinterPainter({
    required this.t,
    required this.loop,
    required this.finish,
    required this.phase,
  });

  final PrinterTheme t;
  final double loop;
  final double finish;
  final PrintPhase phase;

  static const _paper = Color(0xFFFFFFFF);
  static const _ink = Color(0xFF3A3F4B);

  double _seg(double a, double b) =>
      ((loop - a) / (b - a)).clamp(0.0, 1.0).toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final phone = Rect.fromCenter(
      center: Offset(cx - 88, size.height * .58),
      width: 62,
      height: 112,
    );
    final printerBody = Rect.fromCenter(
      center: Offset(cx + 82, size.height * .72),
      width: 104,
      height: 64,
    );
    final slot = Offset(printerBody.center.dx, printerBody.top + 10);

    final done = phase == PrintPhase.success;
    final failed = phase == PrintPhase.error;
    final shake =
        failed ? math.sin(finish * math.pi * 6) * 5 * (1 - finish) : 0.0;

    _drawPhone(canvas, phone);
    _drawLink(canvas, phone, slot, failed);

    // Papel saliendo de la impresora (detrás del cuerpo).
    final paperOut = done
        ? 1.0
        : failed
            ? .35
            : Curves.easeOut.transform(_seg(.62, 1));
    _drawPrintedPaper(canvas, slot.translate(shake, 0), paperOut, done);

    _drawPrinter(canvas, printerBody.shift(Offset(shake, 0)), failed);

    if (!done && !failed) {
      _drawTicketOnPhone(canvas, phone);
      _drawFlyingTicket(canvas, phone, slot);
    }

    if (done || failed) {
      final c = Offset(
        printerBody.right - 4 + shake,
        printerBody.top - 6 - 70 * (done ? 1 : .35),
      );
      _drawBadge(canvas, c, done ? t.success : t.danger, done, finish);
    }
  }

  void _drawPhone(Canvas canvas, Rect r) {
    final body = RRect.fromRectAndRadius(r, const Radius.circular(12));
    canvas.drawRRect(body, Paint()..color = t.card);
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = t.text.withValues(alpha: .75),
    );
    final screen = r.deflate(6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, const Radius.circular(7)),
      Paint()..color = t.soft(t.primary),
    );
    // Isla superior.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(r.center.dx, r.top + 9), width: 16, height: 4),
        const Radius.circular(2),
      ),
      Paint()..color = t.text.withValues(alpha: .5),
    );
  }

  /// Comprobante en la pantalla: se arma y sale por el borde superior.
  void _drawTicketOnPhone(Canvas canvas, Rect phone) {
    final screen = phone.deflate(6);
    final build = Curves.easeOut.transform(_seg(0, .12));
    final lift = Curves.easeInCubic.transform(_seg(.12, .30));
    if (lift >= 1) return;

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(screen, const Radius.circular(7)));
    final w = screen.width - 12;
    const h = 62.0;
    final top = screen.top + 14 - lift * (h + 20) + (1 - build) * 10;
    final rect = Rect.fromLTWH(screen.left + 6, top, w, h);
    _drawTicket(canvas, rect, opacity: build);
    canvas.restore();
  }

  /// Comprobante en vuelo: arco del teléfono a la ranura.
  void _drawFlyingTicket(Canvas canvas, Rect phone, Offset slot) {
    final f = _seg(.28, .62);
    if (f <= 0 || f >= 1) return;
    final start = Offset(phone.center.dx, phone.top - 6);
    final end = slot.translate(0, -6);
    final control = Offset((start.dx + end.dx) / 2, -18);

    Offset at(double s) {
      final u = 1 - s;
      return start * (u * u) + control * (2 * u * s) + end * (s * s);
    }

    final e = Curves.easeInOut.transform(f);
    // Estela.
    for (var i = 1; i <= 5; i++) {
      final s = e - i * .045;
      if (s <= 0) continue;
      canvas.drawCircle(
        at(s),
        2.6 - i * .35,
        Paint()..color = t.primary.withValues(alpha: .55 - i * .09),
      );
    }
    final pos = at(e);
    final scale = 1 - e * .45;
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate((e - .5) * .5);
    canvas.scale(scale);
    _drawTicket(canvas, const Rect.fromLTWH(-20, -26, 40, 52));
    canvas.restore();
  }

  void _drawTicket(Canvas canvas, Rect r, {double opacity = 1}) {
    final paper = Paint()..color = _paper.withValues(alpha: opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()
        ..color = Colors.black.withValues(alpha: .18 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(3)), paper);
    final ink = Paint()
      ..color = _ink.withValues(alpha: .7 * opacity)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final lines = [.62, .85, .5, .75, .4];
    for (var i = 0; i < lines.length; i++) {
      final y = r.top + 8 + i * (r.height - 14) / lines.length;
      canvas.drawLine(
        Offset(r.left + 6, y),
        Offset(r.left + 6 + (r.width - 12) * lines[i], y),
        ink,
      );
    }
  }

  /// Señal Bluetooth punteada entre los dos equipos.
  void _drawLink(Canvas canvas, Rect phone, Offset slot, bool failed) {
    final start = Offset(phone.right + 6, phone.center.dy + 6);
    final end = Offset(slot.dx - 58, slot.dy + 22);
    final color = failed ? t.danger : t.primary;
    const n = 7;
    for (var i = 0; i < n; i++) {
      final s = i / (n - 1);
      final p = Offset.lerp(start, end, s)!;
      final wave =
          failed ? .3 : (math.sin((loop * 2 - s) * math.pi * 2) + 1) / 2;
      canvas.drawCircle(
        p,
        2.2,
        Paint()..color = color.withValues(alpha: .25 + .6 * wave),
      );
    }
    if (failed) {
      final mid = Offset.lerp(start, end, .5)!;
      final x = Paint()
        ..color = t.danger
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(mid.translate(-6, -6), mid.translate(6, 6), x);
      canvas.drawLine(mid.translate(6, -6), mid.translate(-6, 6), x);
    }
  }

  /// Papel que sale hacia arriba de la ranura con las líneas impresas.
  void _drawPrintedPaper(Canvas canvas, Offset slot, double out, bool done) {
    if (out <= 0) return;
    const w = 66.0;
    const maxH = 84.0;
    final h = maxH * out;
    final rect = Rect.fromLTWH(slot.dx - w / 2, slot.dy - h, w, h);

    // Borde de corte en zigzag arriba.
    final path = Path()..moveTo(rect.left, rect.bottom);
    path.lineTo(rect.left, rect.top + 4);
    const teeth = 8;
    for (var i = 0; i < teeth; i++) {
      final x0 = rect.left + i * w / teeth;
      path.lineTo(x0 + w / teeth / 2, rect.top);
      path.lineTo(x0 + w / teeth, rect.top + 4);
    }
    path.lineTo(rect.right, rect.bottom);
    path.close();

    canvas.drawPath(
      path.shift(const Offset(0, 1)),
      Paint()
        ..color = Colors.black.withValues(alpha: .15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(path, Paint()..color = _paper);

    // Las líneas aparecen desde la ranura hacia arriba, como al imprimir.
    final ink = Paint()
      ..color = _ink.withValues(alpha: .75)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final lens = [.45, .8, .6, .9, .5, .7, .35];
    for (var i = 0; i < lens.length; i++) {
      final y = rect.top + 12 + i * 10.0;
      if (y > rect.bottom - 4) break;
      final cxLine = i == 0 || i == lens.length - 1;
      final len = (w - 16) * lens[i];
      final x = cxLine ? slot.dx - len / 2 : rect.left + 8;
      canvas.drawLine(Offset(x, y), Offset(x + len, y), ink);
    }
  }

  void _drawPrinter(Canvas canvas, Rect r, bool failed) {
    final body = RRect.fromRectAndRadius(r, const Radius.circular(14));
    canvas.drawRRect(
      body.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: t.isDark ? .35 : .12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(body, Paint()..color = t.fill(t.isDark ? t.card : t.text));
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = t.isDark ? t.border : Colors.transparent,
    );
    // Ranura.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(r.center.dx, r.top + 10), width: 76, height: 6),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.black.withValues(alpha: .55),
    );
    // LED de estado: parpadea al imprimir.
    final ledColor = failed
        ? t.danger
        : phase == PrintPhase.success
            ? t.success
            : t.primary;
    final blink = failed || phase == PrintPhase.success
        ? 1.0
        : (math.sin(loop * math.pi * 8) + 1) / 2;
    final led = Offset(r.right - 16, r.bottom - 16);
    canvas.drawCircle(
      led,
      7,
      Paint()
        ..color = ledColor.withValues(alpha: .35 * blink)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(led, 3.6, Paint()..color = ledColor);
    // Botones.
    final btn = Paint()..color = Colors.white.withValues(alpha: .28);
    for (var i = 0; i < 2; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(r.left + 14 + i * 18, r.bottom - 19, 12, 6),
          const Radius.circular(3),
        ),
        btn,
      );
    }
  }

  void _drawBadge(Canvas canvas, Offset c, Color color, bool ok, double k) {
    if (k <= 0) return;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(k);
    canvas.drawCircle(Offset.zero, 15, Paint()..color = t.sheet);
    canvas.drawCircle(Offset.zero, 13, Paint()..color = t.fill(color));
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    if (ok) {
      canvas.drawPath(
        Path()
          ..moveTo(-5.5, .5)
          ..lineTo(-1.5, 4.5)
          ..lineTo(6, -4),
        p,
      );
    } else {
      canvas.drawLine(const Offset(0, -6), const Offset(0, 2), p);
      canvas.drawCircle(const Offset(0, 6), 1.6, p..style = PaintingStyle.fill);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PhoneToPrinterPainter old) =>
      old.loop != loop ||
      old.finish != finish ||
      old.phase != phase ||
      old.t.isDark != t.isDark;
}
