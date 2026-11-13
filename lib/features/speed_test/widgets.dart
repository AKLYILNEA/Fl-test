import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/traffic_chart.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

import 'gauge.dart';

Color speedUploadColor(BuildContext context) =>
    DashboardColors.of(context).complement;

String speedTestBytes(int bytes) => bytes >= 1000000000
    ? '${(bytes / 1000000000).toStringAsFixed(2)} GB'
    : '${(bytes / 1000000).toStringAsFixed(1)} MB';

String speedProtocolLabel(String value) => switch (value) {
  'h3' => 'HTTP/3',
  'h2' => 'HTTP/2',
  _ => 'HTTP/1.1',
};

String _loadedLatency(SpeedTestState? state) {
  if (state == null || state.downloadLatency <= 0 && state.uploadLatency <= 0) {
    return '— ms';
  }
  return '${[if (state.downloadLatency > 0) '↓${state.downloadLatency.round()}', if (state.uploadLatency > 0) '↑${state.uploadLatency.round()}'].join(' ')} ms';
}

class SpeedTestMetrics extends StatelessWidget {
  const SpeedTestMetrics({super.key, this.state, this.speedsOnly = false});
  final bool speedsOnly;
  final SpeedTestState? state;

  Widget _speed(BuildContext context, bool up) {
    final l = context.appLocalizations;
    final s = state;
    final value = s == null
        ? null
        : up
        ? s.phase == SpeedTestPhase.upload
              ? s.speed
              : s.upload
        : s.phase == SpeedTestPhase.download
        ? s.speed
        : s.download;
    final color = up ? speedUploadColor(context) : context.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 6,
          children: [
            GlyphIcon(
              up ? AppGlyphs.arrowUp : AppGlyphs.arrowDown,
              color: color,
              size: 16,
            ),
            Flexible(
              child: Text(
                up ? l.upload : l.download,
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: value == null || value < 0 ? '—' : speedTestValue(value),
                style: AppTextStyle.title2
                    .of(context, emphasized: true)
                    .toTabular
                    .copyWith(color: color),
              ),
              TextSpan(
                text: ' ${speedTestUnit(value ?? 0)}',
                style: AppTextStyle.caption1
                    .of(context)
                    .copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(
    BuildContext context,
    String label,
    double? value,
    String unit, {
    String? text,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyle.footnote
            .of(context)
            .copyWith(color: context.colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 4),
      Text(
        text ?? '${value == null || value <= 0 ? '—' : value.round()} $unit',
        style: AppTextStyle.headline.of(context).toTabular,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final s = state;
    if (speedsOnly) {
      return Row(
        children: [
          Expanded(child: _speed(context, false)),
          const SizedBox(width: 16),
          Expanded(child: _speed(context, true)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _speed(context, false)),
            const SizedBox(width: 16),
            Expanded(child: _speed(context, true)),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _stat(context, l.delay, s?.latency, 'ms')),
            const SizedBox(width: 16),
            Expanded(child: _stat(context, l.speedTestJitter, s?.jitter, 'ms')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _stat(
                context,
                l.speedTestLoadedLatency,
                s == null
                    ? null
                    : s.uploadLatency > 0
                    ? s.uploadLatency
                    : s.downloadLatency,
                'ms',
                text: _loadedLatency(s),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _stat(
                context,
                l.speedTestResponsiveness,
                s?.rpm.toDouble(),
                'RPM',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SpeedTestStatGrid extends StatelessWidget {
  const SpeedTestStatGrid({super.key, this.state, this.testing = false});
  final SpeedTestState? state;
  final bool testing;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final s = state;
    final latencyActive = testing && s?.phase == SpeedTestPhase.latency;
    final loadActive =
        testing &&
        (s?.phase == SpeedTestPhase.download ||
            s?.phase == SpeedTestPhase.upload);
    String number(double? value) =>
        value == null || value <= 0 ? '\u2014' : value.round().toString();
    final items = [
      (l.delay, number(s?.latency), 'ms', latencyActive),
      (l.speedTestJitter, number(s?.jitter), 'ms', latencyActive),
      (
        l.speedTestLoadedLatency,
        _loadedLatency(s).replaceAll(' ms', ''),
        'ms',
        loadActive,
      ),
      (l.speedTestResponsiveness, number(s?.rpm.toDouble()), 'RPM', loadActive),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: Card(
                  radius: AppCorner.xl,
                  padding: const EdgeInsets.all(16),
                  isSelected: item.$4,
                  selectionTint: item.$4
                      ? Color.alphaBlend(
                          context.colorScheme.primary.withValues(alpha: .1),
                          context.colorScheme.surface,
                        )
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.$1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.footnote
                                  .of(context)
                                  .copyWith(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: item.$4
                                ? const ActivityIndicator(size: 12)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 38,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.$2,
                            style: AppTextStyle.largeTitle
                                .of(context, emphasized: true)
                                .toTabular,
                          ),
                        ),
                      ),
                      Text(
                        item.$3,
                        style: AppTextStyle.caption1
                            .of(context)
                            .copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class SpeedTestWaveform extends StatelessWidget {
  const SpeedTestWaveform({super.key, required this.samples});
  final List<Traffic> samples;

  Widget _chart(BuildContext context, {bool? upload}) {
    final l = context.appLocalizations;
    final down = context.colorScheme.primary;
    final up = speedUploadColor(context);
    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            upload == null
                ? l.speedTestRealtime
                : upload
                ? l.upload
                : l.download,
            style: AppTextStyle.headline.of(context, emphasized: true),
          ),
          const SizedBox(height: 20),
          RepaintBoundary(
            child: SizedBox(
              height: 144,
              child: TrafficBarsChart(
                samples: samples,
                capacity: 60,
                downColor: down,
                upColor: up,
                baselineColor: Divider.colorOf(context),
                upload: upload,
              ),
            ),
          ),
          if (upload == null) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                for (final isUp in [false, true])
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      GlyphIcon(
                        isUp ? AppGlyphs.arrowUp : AppGlyphs.arrowDown,
                        color: isUp ? up : down,
                        size: 14,
                      ),
                      Text(
                        isUp ? l.upload : l.download,
                        style: AppTextStyle.footnote.of(context),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 640
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _chart(context, upload: false)),
              const SizedBox(width: 12),
              Expanded(child: _chart(context, upload: true)),
            ],
          )
        : _chart(context),
  );
}
