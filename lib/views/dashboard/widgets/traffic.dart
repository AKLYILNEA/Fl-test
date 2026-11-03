import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import 'card.dart';

const _minSpeedScale = 8 * 1024.0;

const _desktopChartLength = 30;

const _phoneChartLength = 46;

const _phoneDirections = [TrafficDirection.download, TrafficDirection.upload];

num _peakOf(Iterable<Traffic> samples, TrafficDirection direction) => samples
    .fold<num>(0, (peak, traffic) => math.max(peak, direction.of(traffic)));

enum TrafficDirection {
  upload,
  download;

  num of(Traffic traffic) => this == upload ? traffic.up : traffic.down;

  Glyph get glyph => this == upload ? AppGlyphs.arrowUp : AppGlyphs.arrowDown;

  String get arrow => this == upload ? '↑' : '↓';

  Color colorOf(BuildContext context) => accentOf(context);

  Color glyphColorOf(BuildContext context) => accentOf(context);

  Color accentOf(BuildContext context) => this == upload
      ? DashboardColors.of(context).complement
      : context.colorScheme.primary;

  String labelOf(BuildContext context) => this == upload
      ? context.appLocalizations.upload
      : context.appLocalizations.download;
}

String _speedUnit(TrafficShow show) => '${show.unit}/s';

class _Figure extends StatelessWidget {
  const _Figure({
    required this.show,
    required this.unit,
    required this.style,
    required this.unitStyle,
  });

  final TrafficShow show;
  final String unit;
  final AppTextStyle style;
  final AppTextStyle unitStyle;

  @override
  Widget build(BuildContext context) {
    final figureStyle = DashboardText.figure(
      context,
      style,
    ).copyWith(fontWeight: FontWeight.w700);
    return Text.rich(
      TextSpan(
        style: figureStyle,
        children: [
          TextSpan(text: show.value),
          TextSpan(
            text: ' $unit',
            style: DashboardText.unit(context, unitStyle),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.clip,
    );
  }
}

class _SpeedChart extends StatelessWidget {
  const _SpeedChart({required this.direction, required this.traffics});

  final TrafficDirection direction;
  final FixedList<Traffic> traffics;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SingleTrafficBarsPainter(
        samples: traffics.list,
        capacity: _desktopChartLength,
        direction: direction,
        color: direction.colorOf(context),
        baselineColor: Divider.colorOf(context),
      ),
    );
  }
}

/// The upload or the download on its own desktop card.
class SpeedCard extends ConsumerWidget {
  const SpeedCard({super.key, required this.direction});

  final TrafficDirection direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final density = DashboardDensityScope.of(context);
    final compact = density.isCompact;
    final scale = DashboardDensityScope.scaleOf(context);
    final padding = dashboardCardPadding(density);
    final appLocalizations = context.appLocalizations;
    final traffics = ref.watch(trafficsProvider);
    final total = ref.watch(
      totalTrafficProvider.select((state) => direction.of(state)),
    );
    final current = direction.of(traffics.list.safeLast(const Traffic()));
    final samples = traffics.list;
    final peak = _peakOf(
      samples.skip(math.max(0, samples.length - _desktopChartLength)),
      direction,
    );
    final speed = current.traffic;
    final chart = RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        height: compact ? 46 : 58,
        child: _SpeedChart(direction: direction, traffics: traffics),
      ),
    );
    return DashboardCard(
      padding: padding,
      semanticLabel: direction.labelOf(context),
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24 * scale,
              child: Row(
                spacing: 8,
                children: [
                  GlyphIcon(
                    direction.glyph,
                    size: 18,
                    color: direction.glyphColorOf(context),
                  ),
                  Text(
                    direction.labelOf(context),
                    maxLines: 1,
                    style: DashboardText.cardTitle(context),
                  ),
                  Expanded(
                    child: Text(
                      appLocalizations.trafficPeak(
                        '${dashboardTraffic(peak)}/s',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: DashboardText.label(context),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: compact ? 6 : 10),
            _Figure(
              show: speed,
              unit: _speedUnit(speed),
              style: compact ? AppTextStyle.largeTitle : AppTextStyle.display,
              unitStyle: AppTextStyle.subheadline,
            ),
            const SizedBox(height: 2),
            Text(
              appLocalizations.trafficTotal(dashboardTraffic(total)),
              maxLines: 1,
              style: DashboardText.label(context),
            ),
            SizedBox(height: compact ? 8 : 10),
            if (constraints.hasBoundedHeight)
              Expanded(child: chart)
            else
              chart,
          ],
        ),
      ),
    );
  }
}

/// The phone's single card: both directions read against one time axis.
class NetworkSpeedCard extends ConsumerWidget {
  const NetworkSpeedCard({super.key});

  static const _chartHeight = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final traffics = ref.watch(trafficsProvider);
    final total = ref.watch(totalTrafficProvider);
    final latest = traffics.list.safeLast(const Traffic());
    final totals = [
      for (final direction in _phoneDirections)
        '${direction.arrow} ${dashboardTraffic(direction.of(total))}',
    ].join(' ');
    final label = DashboardText.label(context);
    return DashboardCard(
      semanticLabel: appLocalizations.networkSpeed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.speed,
            title: appLocalizations.networkSpeed,
            share: 0.65,
            trailing: [
              Text(
                appLocalizations.trafficTotal(totals),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: label,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: _speedSlotWidth(context),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    for (final direction in _phoneDirections)
                      _SpeedFigure(
                        direction: direction,
                        speed: direction.of(latest),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RepaintBoundary(
                  child: SizedBox(
                    width: double.infinity,
                    height: _chartHeight,
                    child: CustomPaint(
                      painter: _TrafficBarsPainter(
                        samples: traffics.list,
                        capacity: _phoneChartLength,
                        downColor: TrafficDirection.download.accentOf(context),
                        upColor: TrafficDirection.upload.accentOf(context),
                        baselineColor: Divider.colorOf(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

double _speedSlotWidth(BuildContext context) {
  final figureStyle = DashboardText.figure(
    context,
    AppTextStyle.title3,
  ).copyWith(fontWeight: FontWeight.w700);
  final unitStyle = DashboardText.unit(context, AppTextStyle.caption1);
  final textScaler = MediaQuery.textScalerOf(context);
  final painter = TextPainter(
    text: TextSpan(
      style: figureStyle,
      children: [
        const TextSpan(text: '888.8'),
        TextSpan(text: ' MB/s', style: unitStyle),
      ],
    ),
    textDirection: Directionality.of(context),
    textScaler: textScaler,
    maxLines: 1,
  )..layout();
  final arrowHeight = textScaler.scale(11.0);
  final arrowWidth = arrowHeight * _SpeedArrow._aspectRatio + 5;
  return arrowWidth + painter.width + 2;
}

class _SpeedFigure extends StatelessWidget {
  const _SpeedFigure({required this.direction, required this.speed});

  final TrafficDirection direction;
  final num speed;

  @override
  Widget build(BuildContext context) {
    final show = speed.traffic;
    final figureStyle = DashboardText.figure(
      context,
      AppTextStyle.title3,
    ).copyWith(fontWeight: FontWeight.w700);
    final textScaler = MediaQuery.textScalerOf(context);
    final painter = TextPainter(
      text: TextSpan(text: '0', style: figureStyle),
      textDirection: Directionality.of(context),
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    final baseline = painter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    final arrowHeight = textScaler.scale(11.0);
    final digitCenterY = baseline - textScaler.scale(5.7);
    final boxCenterY = painter.height / 2;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, digitCenterY - boxCenterY),
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: _SpeedArrow(
                glyph: direction.glyph,
                color: direction.accentOf(context),
                height: arrowHeight,
                opticalOffset: 0,
              ),
            ),
          ),
          _Figure(
            show: show,
            unit: _speedUnit(show),
            style: AppTextStyle.title3,
            unitStyle: AppTextStyle.caption1,
          ),
        ],
      ),
    );
  }
}

/// A compact arrow whose bottom ink aligns flush with the widget's bottom,
/// so [PlaceholderAlignment.baseline] rests the arrow directly on the alphabetic
/// baseline of the adjacent figures without arbitrary pixel translation.
class _SpeedArrow extends StatelessWidget {
  const _SpeedArrow({
    required this.glyph,
    required this.color,
    this.height = 17,
    this.opticalOffset = 0.3,
  });

  final Glyph glyph;
  final Color color;
  final double height;
  final double opticalOffset;

  static const _aspectRatio =
      _SpeedArrowPainter._inkWidth / _SpeedArrowPainter._inkHeight;

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox(
      width: height * _aspectRatio,
      height: height,
      child: CustomPaint(
        painter: _SpeedArrowPainter(
          glyph: glyph,
          color: color,
          opticalOffset: opticalOffset,
        ),
      ),
    );
    if (glyph.matchTextDirection &&
        Directionality.of(context) == TextDirection.rtl) {
      return Transform.flip(flipX: true, child: icon);
    }
    return icon;
  }
}

class _SpeedArrowPainter extends CustomPainter {
  const _SpeedArrowPainter({
    required this.glyph,
    required this.color,
    this.opticalOffset = 0.3,
  });

  final Glyph glyph;
  final Color color;
  final double opticalOffset;

  static const _inkTop = 4.1;
  static const _inkBottom = 19.9;
  static const _inkHeight = _inkBottom - _inkTop;
  static const _inkLeft = 4.6;
  static const _inkRight = 19.4;
  static const _inkWidth = _inkRight - _inkLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / _inkHeight;
    canvas.save();
    final dx = (size.width - _inkWidth * scale) / 2 - _inkLeft * scale;
    final dy = -_inkTop * scale + opticalOffset;
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = Glyph.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final shape in glyph.shapes) {
      canvas.drawPath(shape.path, line);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpeedArrowPainter oldDelegate) =>
      glyph != oldDelegate.glyph ||
      color != oldDelegate.color ||
      opticalOffset != oldDelegate.opticalOffset;
}

/// Download grows up from the baseline and upload down from it, each on its own
/// scale: upload is usually so much smaller that a shared one would flatten it.
class _TrafficBarsPainter extends CustomPainter {
  const _TrafficBarsPainter({
    required this.samples,
    required this.capacity,
    required this.downColor,
    required this.upColor,
    required this.baselineColor,
  });

  static const _downShare = 0.58;
  static const _barShare = 0.62;
  static const _baselineGap = 2.0;
  static const _oldestOpacity = 0.4;
  static const _minBarLength = 0.01;

  final List<Traffic> samples;
  final int capacity;
  final Color downColor;
  final Color upColor;
  final Color baselineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final baseline = size.height * _downShare;
    canvas.drawLine(
      Offset(0, baseline),
      Offset(size.width, baseline),
      Paint()..color = baselineColor,
    );
    final step = size.width / capacity;
    final barWidth = step * _barShare;
    final inset = _baselineGap + barWidth / 2;
    final downScale = _scaleOf(TrafficDirection.download);
    final upScale = _scaleOf(TrafficDirection.upload);
    final downRoom = baseline - inset - barWidth / 2;
    final upRoom = size.height - baseline - inset - barWidth / 2;
    final bar = Paint()
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;
    for (var age = 0; age < capacity; age++) {
      final sample = age < samples.length
          ? samples[samples.length - 1 - age]
          : const Traffic();
      final x = size.width - step * (age + 0.5);
      final opacity = 1 - (1 - _oldestOpacity) * age / (capacity - 1);
      final top = baseline - inset;
      canvas.drawLine(
        Offset(x, top),
        Offset(x, top - _barLength(sample.down / downScale * downRoom)),
        bar..color = downColor.withValues(alpha: opacity),
      );
      final bottom = baseline + inset;
      canvas.drawLine(
        Offset(x, bottom),
        Offset(x, bottom + _barLength(sample.up / upScale * upRoom)),
        bar..color = upColor.withValues(alpha: opacity),
      );
    }
  }

  /// A renderer may drop a zero-length line, caps included, and an idle second
  /// still has to show its dot.
  double _barLength(double length) => math.max(length, _minBarLength);

  double _scaleOf(TrafficDirection direction) => math.max(
    _minSpeedScale,
    _peakOf(
      samples.skip(math.max(0, samples.length - capacity)),
      direction,
    ).toDouble(),
  );

  @override
  bool shouldRepaint(_TrafficBarsPainter oldDelegate) {
    return !identical(oldDelegate.samples, samples) ||
        oldDelegate.capacity != capacity ||
        oldDelegate.downColor != downColor ||
        oldDelegate.upColor != upColor ||
        oldDelegate.baselineColor != baselineColor;
  }
}

class _SingleTrafficBarsPainter extends CustomPainter {
  const _SingleTrafficBarsPainter({
    required this.samples,
    required this.capacity,
    required this.direction,
    required this.color,
    required this.baselineColor,
  });

  static const _barShare = 0.60;
  static const _baselineGap = 2.0;
  static const _oldestOpacity = 0.4;
  static const _minBarLength = 0.01;

  final List<Traffic> samples;
  final int capacity;
  final TrafficDirection direction;
  final Color color;
  final Color baselineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final baseline = size.height - 0.5;
    canvas.drawLine(
      Offset(0, baseline),
      Offset(size.width, baseline),
      Paint()..color = baselineColor,
    );
    final step = size.width / capacity;
    final barWidth = step * _barShare;
    final inset = _baselineGap + barWidth / 2;
    final scale = math.max(
      _minSpeedScale,
      _peakOf(
        samples.skip(math.max(0, samples.length - capacity)),
        direction,
      ).toDouble(),
    );
    final room = math.max(0.0, baseline - inset - barWidth / 2);
    final bar = Paint()
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;
    final bottom = baseline - inset;
    for (var age = 0; age < capacity; age++) {
      final sample = age < samples.length
          ? samples[samples.length - 1 - age]
          : const Traffic();
      final x = size.width - step * (age + 0.5);
      final opacity = 1 - (1 - _oldestOpacity) * age / (capacity - 1);
      final length = math.max(
        direction.of(sample) / scale * room,
        _minBarLength,
      );
      canvas.drawLine(
        Offset(x, bottom),
        Offset(x, bottom - length),
        bar..color = color.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_SingleTrafficBarsPainter oldDelegate) {
    return !identical(oldDelegate.samples, samples) ||
        oldDelegate.capacity != capacity ||
        oldDelegate.direction != direction ||
        oldDelegate.color != color ||
        oldDelegate.baselineColor != baselineColor;
  }
}
