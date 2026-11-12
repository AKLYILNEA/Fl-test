import 'dart:math';
import 'dart:ui' as ui;
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

const _gaugeMarks = [0.0, 5.0, 10.0, 50.0, 100.0, 250.0, 500.0, 750.0, 1000.0];
String speedTestValue(double bps) => bps < 0
    ? '—'
    : bps >= 1e9
    ? (bps / 1e9).toStringAsFixed(2)
    : (bps / 1e6).toStringAsFixed(1);
String speedTestUnit(double bps) => bps >= 1e9 ? 'Gbps' : 'Mbps';
double speedGaugeFraction(double bps) {
  final mbps = bps / 1e6;
  if (mbps <= 0) return 0;
  final segments = _gaugeMarks.length - 1;
  for (var i = 0; i < segments; i++) {
    final low = _gaugeMarks[i], high = _gaugeMarks[i + 1];
    if (mbps <= high) return (i + (mbps - low) / (high - low)) / segments;
  }
  return 1;
}

class SpeedTestGauge extends StatefulWidget {
  const SpeedTestGauge({
    super.key,
    this.state,
    required this.waiting,
    required this.color,
    required this.otherColor,
  });
  final SpeedTestState? state;
  final bool waiting;
  final Color color;
  final Color otherColor;
  @override
  State<SpeedTestGauge> createState() => _SpeedTestGaugeState();
}

class _SpeedTestGaugeState extends State<SpeedTestGauge>
    with SingleTickerProviderStateMixin {
  late final _spinner = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  void _sync() {
    if (widget.waiting && !MediaQuery.disableAnimationsOf(context)) {
      if (!_spinner.isAnimating) {
        _spinner.repeat(reverse: true);
      }
    } else {
      _spinner.reset();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant SpeedTestGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _spinner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final state = widget.state;
    final phase = state?.error.isNotEmpty == true ? null : state?.phase;
    final value = phase == SpeedTestPhase.done
        ? state!.download
        : state?.speed ?? 0;
    final label = switch (phase) {
      SpeedTestPhase.download || SpeedTestPhase.done => l.download,
      SpeedTestPhase.upload => l.upload,
      SpeedTestPhase.latency => l.delay,
      SpeedTestPhase.connecting => l.speedTestConnecting,
      _ => widget.waiting ? l.speedTestProbing : l.speedTestReady,
    };
    final measured =
        phase == SpeedTestPhase.download ||
        phase == SpeedTestPhase.upload ||
        phase == SpeedTestPhase.done;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = min(320.0, constraints.maxWidth);
        return Center(
          child: SizedBox(
            width: width,
            height: width * .94,
            child: RepaintBoundary(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: speedGaugeFraction(value)),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (context, fraction, _) => AnimatedBuilder(
                  animation: _spinner,
                  builder: (context, _) => CustomPaint(
                    painter: _GaugePainter(
                      fraction: fraction,
                      color: widget.color,
                      startColor: widget.otherColor,
                      trackColor: context.colorScheme.onSurface.withValues(
                        alpha: .06,
                      ),
                      needleColor: widget.color,
                      labelStyle: AppTextStyle.caption2
                          .of(context)
                          .copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                      passedLabelColor: context.colorScheme.onSurface,
                      spin: _spinner.isAnimating
                          ? Curves.easeInOut.transform(_spinner.value)
                          : null,
                      showNeedle: measured,
                    ),
                    child: Align(
                      alignment: const Alignment(0, .48),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: AppTextStyle.footnote
                                .of(context)
                                .copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                          ),
                          Text(
                            measured ? speedTestValue(value) : '0.0',
                            style: AppTextStyle.display
                                .of(context, emphasized: true)
                                .toTabular,
                          ),
                          Text(
                            speedTestUnit(value),
                            style: AppTextStyle.footnote
                                .of(context)
                                .copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction;
  final Color color;
  final Color startColor;
  final Color trackColor;
  final Color needleColor;
  final TextStyle labelStyle;
  final Color passedLabelColor;
  final double? spin;
  final bool showNeedle;

  _GaugePainter({
    required this.fraction,
    required this.color,
    required this.startColor,
    required this.trackColor,
    required this.needleColor,
    required this.labelStyle,
    required this.passedLabelColor,
    required this.spin,
    required this.showNeedle,
  });

  static const _start = pi * 0.75;
  static const _sweep = pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width / 13;
    final center = Offset(size.width / 2, size.width / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, _start, _sweep, false, stroke..color = trackColor);

    final sweep = _sweep * fraction;
    if (fraction > 0.002) {
      canvas.drawArc(
        rect,
        _start,
        sweep,
        false,
        stroke
          ..color = color
          ..shader = SweepGradient(
            endAngle: _sweep,
            colors: [startColor, color],
            transform: const GradientRotation(_start),
          ).createShader(rect),
      );
      stroke.shader = null;
      // The rounded start cap crosses the sweep shader's seam.
      canvas.drawCircle(
        center + Offset(cos(_start), sin(_start)) * radius,
        strokeWidth / 2,
        Paint()..color = startColor,
      );
    }

    final spin = this.spin;
    if (spin != null) {
      const length = pi / 5;
      canvas.drawArc(
        rect,
        _start + (_sweep - length) * spin,
        length,
        false,
        stroke..color = color.withValues(alpha: 0.7),
      );
    }

    final labelRadius = radius - strokeWidth / 2 - size.width * 0.085;
    final segments = _gaugeMarks.length - 1;
    for (var i = 0; i < _gaugeMarks.length; i++) {
      final position = i / segments;
      final angle = _start + _sweep * position;
      final mark = _gaugeMarks[i];
      final text = i == segments ? '1G+' : mark.toStringAsFixed(0);
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: position <= fraction + 0.001
              ? labelStyle.copyWith(color: passedLabelColor)
              : labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelCenter = center + Offset(cos(angle), sin(angle)) * labelRadius;
      painter.paint(
        canvas,
        labelCenter - Offset(painter.width / 2, painter.height / 2),
      );
    }

    if (!showNeedle) return;
    final angle = _start + sweep;
    final direction = Offset(cos(angle), sin(angle));
    final normal = Offset(-direction.dy, direction.dx);
    final outer = size.width / 2;
    final base = center - direction * outer * 0.1;
    final tip = center + direction * outer * 0.5;
    final baseHalf = outer * 0.03;
    final tipHalf = outer * 0.018;
    final needle = Path()
      ..moveTo(base.dx + normal.dx * baseHalf, base.dy + normal.dy * baseHalf)
      ..lineTo(tip.dx + normal.dx * tipHalf, tip.dy + normal.dy * tipHalf)
      ..lineTo(tip.dx - normal.dx * tipHalf, tip.dy - normal.dy * tipHalf)
      ..lineTo(base.dx - normal.dx * baseHalf, base.dy - normal.dy * baseHalf)
      ..close();
    canvas.drawPath(
      needle,
      Paint()
        ..shader = ui.Gradient.linear(
          base,
          tip,
          [
            needleColor.withValues(alpha: 0),
            needleColor.withValues(alpha: 0.35),
            needleColor.withValues(alpha: 0.9),
          ],
          const [0, 0.4, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.color != color ||
        oldDelegate.startColor != startColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.needleColor != needleColor ||
        oldDelegate.passedLabelColor != passedLabelColor ||
        oldDelegate.spin != spin ||
        oldDelegate.showNeedle != showNeedle ||
        oldDelegate.labelStyle != labelStyle;
  }
}
