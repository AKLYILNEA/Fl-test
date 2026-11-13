import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

import 'ring_chart.dart';
import 'site_icon.dart';

class TrafficStatsScope extends StatelessWidget {
  const TrafficStatsScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(visualDensity: VisualDensity.standard),
    child: child,
  );
}

enum TrafficStatsPeriod { day, week, month }

enum TrafficStatsRankTab { domain, process, node, profile }

Color trafficUploadColor(BuildContext context) =>
    DashboardColors.of(context).complement;

Color trafficDownloadColor(BuildContext context) =>
    context.colorScheme.primary;

Color trafficDirectColor(BuildContext context) =>
    DashboardColors.of(context).complement;

String trafficStatsDayKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _weekStart(DateTime date) {
  final d = _dateOnly(date);
  return d.subtract(Duration(days: d.weekday - DateTime.monday));
}

DateTime _monthEnd(int year, int month) => DateTime(year, month + 1, 0);

(String start, String end) trafficStatsDateRange(
  TrafficStatsPeriod period,
  DateTime anchor,
) {
  final d = _dateOnly(anchor);
  switch (period) {
    case TrafficStatsPeriod.day:
      final key = trafficStatsDayKey(d);
      return (key, key);
    case TrafficStatsPeriod.week:
      final start = _weekStart(d);
      final end = start.add(const Duration(days: 6));
      return (trafficStatsDayKey(start), trafficStatsDayKey(end));
    case TrafficStatsPeriod.month:
      final start = DateTime(d.year, d.month, 1);
      final end = _monthEnd(d.year, d.month);
      return (trafficStatsDayKey(start), trafficStatsDayKey(end));
  }
}

DateTime trafficStatsStepAnchor(
  TrafficStatsPeriod period,
  DateTime anchor,
  int delta,
) {
  final d = _dateOnly(anchor);
  switch (period) {
    case TrafficStatsPeriod.day:
      return d.add(Duration(days: delta));
    case TrafficStatsPeriod.week:
      return d.add(Duration(days: delta * 7));
    case TrafficStatsPeriod.month:
      return DateTime(d.year, d.month + delta, 1);
  }
}

bool trafficStatsCanStepForward(
  TrafficStatsPeriod period,
  DateTime anchor, [
  DateTime? now,
]) {
  final current = _dateOnly(now ?? DateTime.now());
  final d = _dateOnly(anchor);
  switch (period) {
    case TrafficStatsPeriod.day:
      return d.isBefore(current);
    case TrafficStatsPeriod.week:
      return _weekStart(d).isBefore(_weekStart(current));
    case TrafficStatsPeriod.month:
      return d.year < current.year ||
          (d.year == current.year && d.month < current.month);
  }
}

String trafficStatsPeriodLabel(TrafficStatsPeriod period, DateTime anchor) {
  final d = _dateOnly(anchor);
  switch (period) {
    case TrafficStatsPeriod.day:
      return trafficStatsDayKey(d);
    case TrafficStatsPeriod.week:
      final start = _weekStart(d);
      final end = start.add(const Duration(days: 6));
      String mmdd(DateTime v) =>
          '${v.month.toString().padLeft(2, '0')}/${v.day.toString().padLeft(2, '0')}';
      if (start.year != end.year) {
        return '${trafficStatsDayKey(start)} \u2013 ${trafficStatsDayKey(end)}';
      }
      return '${start.year} ${mmdd(start)} \u2013 ${mmdd(end)}';
    case TrafficStatsPeriod.month:
      return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
  }
}

String trafficStatsFormatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  final show = bytes.traffic;
  return '${show.value} ${show.unit}';
}

String trafficStatsFormatAxisBytes(int bytes) {
  if (bytes <= 0) return '0';
  final show = bytes.traffic;
  return '${show.value}${show.unit}';
}

class _GlyphBadge extends StatelessWidget {
  const _GlyphBadge({
    required this.glyph,
    required this.color,
    this.size = 28,
    this.iconSize = 16,
  });

  final Glyph glyph;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.14),
        shape: AppShape.all(AppCorner.sm),
      ),
      child: GlyphIcon(glyph, size: iconSize, color: color),
    );
  }
}

class TrafficStatsPeriodBar extends StatelessWidget {
  const TrafficStatsPeriodBar({
    super.key,
    required this.period,
    required this.anchor,
    required this.onPeriodChanged,
    required this.onStep,
  });

  final TrafficStatsPeriod period;
  final DateTime anchor;
  final ValueChanged<TrafficStatsPeriod> onPeriodChanged;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final canForward = trafficStatsCanStepForward(period, anchor);
    final segments = SegmentedControl<TrafficStatsPeriod>(
      segments: [
        (TrafficStatsPeriod.day, l.trafficStatsDay),
        (TrafficStatsPeriod.week, l.trafficStatsWeek),
        (TrafficStatsPeriod.month, l.trafficStatsMonth),
      ],
      value: period,
      onChanged: onPeriodChanged,
    );
    final dateStepper = Card(
      radius: AppCorner.full,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            IconButton(
              icon: const GlyphIcon(AppGlyphs.chevronBack, size: 18),
              onPressed: () => onStep(-1),
            ),
            Expanded(
              child: Text(
                trafficStatsPeriodLabel(period, anchor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyle.subheadline
                    .of(context, emphasized: true)
                    .toTabular,
              ),
            ),
            IconButton(
              icon: const GlyphIcon(AppGlyphs.chevronForward, size: 18),
              onPressed: canForward ? () => onStep(1) : null,
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return Row(
            children: [
              SizedBox(width: 248, child: segments),
              const SizedBox(width: 12),
              Expanded(child: dateStepper),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [segments, const SizedBox(height: 10), dateStepper],
        );
      },
    );
  }
}

class TrafficStatsDisabledCard extends StatelessWidget {
  const TrafficStatsDisabledCard({super.key, required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GlyphBadge(
            glyph: AppGlyphs.dataUsage,
            color: cs.primary,
            size: 56,
            iconSize: 28,
          ),
          const SizedBox(height: 16),
          Text(
            l.trafficStatsDisabled,
            textAlign: TextAlign.center,
            style: AppTextStyle.title3.of(context, emphasized: true),
          ),
          const SizedBox(height: 8),
          Text(
            l.trafficStatsDisabledDesc,
            textAlign: TextAlign.center,
            style: AppTextStyle.subheadline
                .of(context)
                .copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onEnable,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(l.trafficStatsEnable),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrafficStatsDisabledBanner extends StatelessWidget {
  const TrafficStatsDisabledBanner({super.key, required this.onEnable});

  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _GlyphBadge(glyph: AppGlyphs.dataUsage, color: cs.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.trafficStatsDisabled,
                  style: AppTextStyle.subheadline.of(context, emphasized: true),
                ),
                const SizedBox(height: 2),
                Text(
                  l.trafficStatsDisabledDesc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.caption1
                      .of(context)
                      .copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onEnable,
            child: Text(l.trafficStatsEnableAction),
          ),
        ],
      ),
    );
  }
}

class TrafficStatsOverviewCard extends StatelessWidget {
  const TrafficStatsOverviewCard({super.key, required this.result});

  final TrafficStatsResult result;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    final upColor = trafficUploadColor(context);
    final downColor = trafficDownloadColor(context);
    final directColor = trafficDirectColor(context);
    final proxyTotal = result.proxyTotal;
    final directTotal = (result.total - proxyTotal).clamp(0, result.total);
    final splitTotal = proxyTotal + directTotal;
    final proxyPct = splitTotal > 0 ? (proxyTotal * 100 / splitTotal).round() : 0;

    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.trafficStatsOverview,
            style: AppTextStyle.headline.of(context, emphasized: true),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.trafficStatsTotal,
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        trafficStatsFormatBytes(result.total),
                        style: AppTextStyle.title1
                            .of(context, emphasized: true)
                            .toTabular,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DirectionalMetric(
                      glyph: AppGlyphs.arrowDown,
                      color: downColor,
                      label: l.download,
                      value: trafficStatsFormatBytes(result.down),
                    ),
                    const SizedBox(height: 8),
                    _DirectionalMetric(
                      glyph: AppGlyphs.arrowUp,
                      color: upColor,
                      label: l.upload,
                      value: trafficStatsFormatBytes(result.up),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RingChart(
                    size: 92,
                    strokeWidth: 7.5,
                    trackColor: cs.surfaceContainerHighest,
                    total: splitTotal > 0 ? splitTotal.toDouble() : null,
                    segments: [
                      RingSegment(
                        value: proxyTotal.toDouble(),
                        color: cs.primary,
                      ),
                      RingSegment(
                        value: directTotal.toDouble(),
                        color: directColor,
                      ),
                    ],
                    centerChild: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$proxyPct%',
                          style: AppTextStyle.subheadline
                              .of(context, emphasized: true)
                              .toTabular,
                        ),
                        Text(
                          l.proxies,
                          style: AppTextStyle.caption2
                              .of(context)
                              .copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SplitLegendRow(
                    color: cs.primary,
                    label: l.proxies,
                    value: trafficStatsFormatBytes(proxyTotal),
                  ),
                  const SizedBox(height: 4),
                  _SplitLegendRow(
                    color: directColor,
                    label: l.direct,
                    value: trafficStatsFormatBytes(directTotal),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DirectionalMetric extends StatelessWidget {
  const _DirectionalMetric({
    required this.glyph,
    required this.color,
    required this.label,
    required this.value,
  });

  final Glyph glyph;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Row(
      children: [
        GlyphIcon(glyph, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.footnote
                .of(context)
                .copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyle.subheadline
              .of(context, emphasized: true)
              .toTabular,
        ),
      ],
    );
  }
}

class _SplitLegendRow extends StatelessWidget {
  const _SplitLegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: ShapeDecoration(color: color, shape: AppShape.full),
        ),
        const SizedBox(width: 5),
        Text(
          '$label ',
          style: AppTextStyle.caption2
              .of(context)
              .copyWith(color: cs.onSurfaceVariant),
        ),
        Text(
          value,
          style: AppTextStyle.caption2.of(context, emphasized: true).toTabular,
        ),
      ],
    );
  }
}

class TrafficStatsTrendCard extends StatefulWidget {
  const TrafficStatsTrendCard({
    super.key,
    required this.points,
    required this.period,
  });

  final List<TrafficStatsPoint> points;
  final TrafficStatsPeriod period;

  @override
  State<TrafficStatsTrendCard> createState() => _TrafficStatsTrendCardState();
}

class _TrafficStatsTrendCardState extends State<TrafficStatsTrendCard> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant TrafficStatsTrendCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points &&
        _selectedIndex != null &&
        _selectedIndex! >= widget.points.length) {
      _selectedIndex = null;
    }
  }

  void _updateIndexFromDx(double dx, double width) {
    final count = widget.points.length;
    if (count == 0) return;
    const leftPad = 44.0;
    const rightPad = 6.0;
    final chartWidth = width - leftPad - rightPad;
    if (chartWidth <= 0) return;
    final rel = ((dx - leftPad) / chartWidth).clamp(0.0, 0.9999);
    final idx = (rel * count).floor().clamp(0, count - 1);
    if (idx != _selectedIndex) {
      setState(() => _selectedIndex = idx);
    }
  }

  String _pointDisplayLabel(TrafficStatsPoint point) {
    switch (widget.period) {
      case TrafficStatsPeriod.day:
        return '${point.label}:00';
      case TrafficStatsPeriod.week:
        final parts = point.label.split('-');
        return parts.length == 3 ? '${parts[1]}/${parts[2]}' : point.label;
      case TrafficStatsPeriod.month:
        return point.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    final upColor = trafficUploadColor(context);
    final downColor = trafficDownloadColor(context);
    final hasAnyTraffic = widget.points.any((p) => p.total > 0);
    final activePoint =
        _selectedIndex != null && _selectedIndex! < widget.points.length
        ? widget.points[_selectedIndex!]
        : null;

    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.trafficStatsTrend,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.headline.of(context, emphasized: true),
                ),
              ),
              const SizedBox(width: 8),
              if (activePoint != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: ShapeDecoration(
                    color: cs.surfaceContainerHighest,
                    shape: AppShape.full,
                  ),
                  child: Text(
                    '${_pointDisplayLabel(activePoint)}  \u2193 ${trafficStatsFormatAxisBytes(activePoint.down)}  \u2191 ${trafficStatsFormatAxisBytes(activePoint.up)}',
                    style: AppTextStyle.caption2
                        .of(context, emphasized: true)
                        .toTabular,
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendDot(color: downColor, label: l.download),
                    const SizedBox(width: 10),
                    _LegendDot(color: upColor, label: l.upload),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 158,
            child: !hasAnyTraffic
                ? Center(
                    child: Text(
                      l.noData,
                      style: AppTextStyle.subheadline
                          .of(context)
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) => MouseRegion(
                      onHover: (e) => _updateIndexFromDx(
                        e.localPosition.dx,
                        constraints.maxWidth,
                      ),
                      onExit: (_) {
                        if (_selectedIndex != null) {
                          setState(() => _selectedIndex = null);
                        }
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (d) => _updateIndexFromDx(
                          d.localPosition.dx,
                          constraints.maxWidth,
                        ),
                        onHorizontalDragUpdate: (d) => _updateIndexFromDx(
                          d.localPosition.dx,
                          constraints.maxWidth,
                        ),
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, 158),
                          painter: _TrendBarPainter(
                            points: widget.points,
                            period: widget.period,
                            selectedIndex: _selectedIndex,
                            downloadColor: downColor,
                            uploadColor: upColor,
                            gridColor: cs.outlineVariant.withValues(alpha: 0.4),
                            highlightColor: cs.primary.withValues(alpha: 0.08),
                            labelStyle: AppTextStyle.caption2
                                .of(context)
                                .toTabular
                                .copyWith(color: cs.onSurfaceVariant),
                            activeLabelStyle: AppTextStyle.caption2
                                .of(context, emphasized: true)
                                .toTabular
                                .copyWith(color: cs.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: ShapeDecoration(color: color, shape: AppShape.full),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyle.caption2
              .of(context)
              .copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _TrendBarPainter extends CustomPainter {
  _TrendBarPainter({
    required this.points,
    required this.period,
    required this.selectedIndex,
    required this.downloadColor,
    required this.uploadColor,
    required this.gridColor,
    required this.highlightColor,
    required this.labelStyle,
    required this.activeLabelStyle,
  });

  final List<TrafficStatsPoint> points;
  final TrafficStatsPeriod period;
  final int? selectedIndex;
  final Color downloadColor;
  final Color uploadColor;
  final Color gridColor;
  final Color highlightColor;
  final TextStyle labelStyle;
  final TextStyle activeLabelStyle;

  static const _leftPad = 44.0;
  static const _rightPad = 6.0;
  static const _topPad = 8.0;
  static const _bottomPad = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final chartLeft = _leftPad;
    final chartRight = size.width - _rightPad;
    final chartTop = _topPad;
    final chartBottom = size.height - _bottomPad;
    final chartWidth = chartRight - chartLeft;
    final chartHeight = chartBottom - chartTop;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    var maxTotal = 0;
    for (final p in points) {
      if (p.total > maxTotal) maxTotal = p.total;
    }
    if (maxTotal <= 0) maxTotal = 1;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;

    const steps = 2;
    for (var s = 0; s <= steps; s++) {
      final frac = s / steps;
      final y = chartBottom - chartHeight * frac;
      canvas.drawLine(Offset(chartLeft, y), Offset(chartRight, y), gridPaint);

      final val = (maxTotal * frac).round();
      final tp = TextPainter(
        text: TextSpan(
          text: trafficStatsFormatAxisBytes(val),
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _leftPad - 6);
      tp.paint(
        canvas,
        Offset(
          _leftPad - 6 - tp.width,
          (y - tp.height / 2).clamp(0.0, chartBottom - tp.height),
        ),
      );
    }

    final count = points.length;
    final slotWidth = chartWidth / count;
    final barWidth = math.max(
      2.5,
      math.min(18.0, slotWidth * (count > 20 ? 0.58 : 0.46)),
    );
    final downPaint = Paint()..color = downloadColor;
    final upPaint = Paint()..color = uploadColor;
    final radius = Radius.circular(math.min(4.0, barWidth / 2));

    for (var i = 0; i < count; i++) {
      final point = points[i];
      final slotLeft = chartLeft + i * slotWidth;
      final cx = slotLeft + slotWidth / 2;
      final isSelected = selectedIndex == i;

      if (isSelected) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(slotLeft, chartTop, slotWidth, chartHeight),
            const Radius.circular(6),
          ),
          Paint()..color = highlightColor,
        );
      }

      if (point.total > 0) {
        final totalH = math.max(2.0, (point.total / maxTotal) * chartHeight);
        final downH = point.down > 0
            ? math.max(1.5, totalH * (point.down / point.total))
            : 0.0;
        final upH = math.max(0.0, totalH - downH);
        final barLeft = cx - barWidth / 2;
        final barRight = cx + barWidth / 2;

        if (downH > 0) {
          final downTop = chartBottom - downH;
          final rrect = upH <= 0.5
              ? RRect.fromLTRBAndCorners(
                  barLeft,
                  downTop,
                  barRight,
                  chartBottom,
                  topLeft: radius,
                  topRight: radius,
                )
              : RRect.fromLTRBR(
                  barLeft,
                  downTop,
                  barRight,
                  chartBottom,
                  Radius.zero,
                );
          canvas.drawRRect(rrect, downPaint);
        }

        if (upH > 0.5) {
          final top = chartBottom - totalH;
          final bottom = chartBottom - downH;
          canvas.drawRRect(
            RRect.fromLTRBAndCorners(
              barLeft,
              top,
              barRight,
              bottom,
              topLeft: radius,
              topRight: radius,
            ),
            upPaint,
          );
        }
      }

      if (_shouldShowTick(i, count)) {
        final tp = TextPainter(
          text: TextSpan(
            text: _shortAxisLabel(point.label),
            style: isSelected ? activeLabelStyle : labelStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final x = (cx - tp.width / 2)
            .clamp(chartLeft, math.max(chartLeft, chartRight - tp.width))
            .toDouble();
        tp.paint(canvas, Offset(x, chartBottom + 6));
      }
    }
  }

  bool _shouldShowTick(int index, int count) {
    switch (period) {
      case TrafficStatsPeriod.day:
        return index == 0 ||
            index == 6 ||
            index == 12 ||
            index == 18 ||
            index == count - 1;
      case TrafficStatsPeriod.week:
        return true;
      case TrafficStatsPeriod.month:
        return index == 0 ||
            index == 7 ||
            index == 14 ||
            index == 21 ||
            index == count - 1;
    }
  }

  String _shortAxisLabel(String raw) {
    switch (period) {
      case TrafficStatsPeriod.day:
        return raw;
      case TrafficStatsPeriod.week:
        final parts = raw.split('-');
        return parts.length == 3 ? '${parts[1]}/${parts[2]}' : raw;
      case TrafficStatsPeriod.month:
        final parts = raw.split('-');
        return parts.length == 3 ? '${int.tryParse(parts[2]) ?? parts[2]}' : raw;
    }
  }

  @override
  bool shouldRepaint(covariant _TrendBarPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.period != period ||
      oldDelegate.selectedIndex != selectedIndex ||
      oldDelegate.downloadColor != downloadColor ||
      oldDelegate.uploadColor != uploadColor ||
      oldDelegate.gridColor != gridColor;
}

class TrafficStatsRuleHitsSection extends StatelessWidget {
  const TrafficStatsRuleHitsSection({
    super.key,
    required this.rules,
    required this.totalHits,
  });

  final List<TrafficStatsItem> rules;
  final int totalHits;

  static const _ringPalette = [
    Color(0xFF4C8DFF),
    Color(0xFF34C759),
    Color(0xFFFF9F0A),
    Color(0xFFAF52DE),
    Color(0xFFFF375F),
    Color(0xFF30B0C7),
  ];

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) return const SizedBox.shrink();
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListHeader(title: l.trafficStatsRuleHits),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rules.length; i++)
                  _RuleHitCard(
                    item: rules[i],
                    totalHits: totalHits,
                    accent: _ringPalette[i % _ringPalette.length],
                    hitCountText: l.trafficStatsHitCount(rules[i].hits),
                    trackColor: cs.surfaceContainerHighest,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RuleHitCard extends StatelessWidget {
  const _RuleHitCard({
    required this.item,
    required this.totalHits,
    required this.accent,
    required this.hitCountText,
    required this.trackColor,
  });

  final TrafficStatsItem item;
  final int totalHits;
  final Color accent;
  final String hitCountText;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final pct = totalHits > 0 ? (item.hits * 100 / totalHits).round() : 0;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 176, maxWidth: 220),
      child: Card(
        radius: AppCorner.xl,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            RingChart(
              size: 46,
              strokeWidth: 4.5,
              trackColor: trackColor,
              total: totalHits > 0 ? totalHits.toDouble() : null,
              segments: [
                RingSegment(value: item.hits.toDouble(), color: accent),
              ],
              centerChild: Text(
                '$pct%',
                style: AppTextStyle.caption2
                    .of(context, emphasized: true)
                    .toTabular,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.subheadline.of(
                      context,
                      emphasized: true,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hitCountText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption1
                        .of(context)
                        .toTabular
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                  Text(
                    trafficStatsFormatBytes(item.total),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption1
                        .of(context, emphasized: true)
                        .toTabular
                        .copyWith(color: cs.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrafficStatsRankingSection extends StatelessWidget {
  const TrafficStatsRankingSection({
    super.key,
    required this.result,
    required this.settings,
    required this.tab,
    required this.onTabChanged,
  });

  final TrafficStatsResult result;
  final TrafficStatsSettings settings;
  final TrafficStatsRankTab tab;
  final ValueChanged<TrafficStatsRankTab> onTabChanged;

  List<TrafficStatsItem> _itemsForTab() {
    switch (tab) {
      case TrafficStatsRankTab.domain:
        return result.hosts;
      case TrafficStatsRankTab.process:
        return result.processes;
      case TrafficStatsRankTab.node:
        return result.nodes;
      case TrafficStatsRankTab.profile:
        return result.profiles;
    }
  }

  Widget _leadingForItem(BuildContext context, TrafficStatsItem item) {
    final cs = context.colorScheme;
    switch (tab) {
      case TrafficStatsRankTab.domain:
        return SiteIcon(
          domain: item.name,
          enabled: settings.siteIcon,
          size: 28,
        );
      case TrafficStatsRankTab.process:
        if (system.isAndroid && item.name.contains('.')) {
          return ClipRRect(
            borderRadius: AppRadius.all(AppCorner.sm),
            child: PackageIcon(packageName: item.name, size: 28),
          );
        }
        return _GlyphBadge(glyph: AppGlyphs.appsList, color: cs.primary);
      case TrafficStatsRankTab.node:
        return _GlyphBadge(glyph: AppGlyphs.proxies, color: cs.primary);
      case TrafficStatsRankTab.profile:
        return _GlyphBadge(glyph: AppGlyphs.profiles, color: cs.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    final items = _itemsForTab();
    final maxItemTotal = items.isNotEmpty
        ? items.fold<int>(0, (prev, item) => math.max(prev, item.total))
        : 0;
    final sumTotal = result.total > 0
        ? result.total
        : items.fold<int>(0, (prev, item) => prev + item.total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListHeader(title: l.trafficStatsRanking),
        if (!settings.detail) ...[
          Card(
            radius: AppCorner.lg,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                GlyphIcon(AppGlyphs.info, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.trafficStatsDetailOffTip,
                    style: AppTextStyle.caption1
                        .of(context)
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        SegmentedControl<TrafficStatsRankTab>(
          segments: [
            (TrafficStatsRankTab.domain, l.domain),
            (TrafficStatsRankTab.process, l.process),
            (TrafficStatsRankTab.node, l.trafficStatsNode),
            (TrafficStatsRankTab.profile, l.profile),
          ],
          value: tab,
          onChanged: onTabChanged,
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Card(
            radius: AppCorner.xl,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Center(
              child: Text(
                l.noData,
                style: AppTextStyle.subheadline
                    .of(context)
                    .copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          )
        else
          generateGroup([
            for (final item in items)
              DecorationListItem(
                leading: _leadingForItem(context, item),
                title: tab == TrafficStatsRankTab.node ||
                        tab == TrafficStatsRankTab.profile
                    ? EmojiText(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: AppRadius.full,
                      child: SizedBox(
                        height: 4,
                        width: double.infinity,
                        child: ColoredBox(
                          color: cs.surfaceContainerHighest,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: FractionallySizedBox(
                              widthFactor: maxItemTotal > 0
                                  ? (item.total / maxItemTotal).clamp(0.02, 1.0)
                                  : 0,
                              child: ColoredBox(color: cs.primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '\u2193 ${trafficStatsFormatBytes(item.down)}   \u2191 ${trafficStatsFormatBytes(item.up)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.caption1
                          .of(context)
                          .toTabular
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trafficStatsFormatBytes(item.total),
                      style: AppTextStyle.subheadline
                          .of(context, emphasized: true)
                          .toTabular,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sumTotal > 0
                          ? '${(item.total * 100 / sumTotal).toStringAsFixed(1)}%'
                          : '0.0%',
                      style: AppTextStyle.caption2
                          .of(context)
                          .toTabular
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
          ]),
      ],
    );
  }
}
