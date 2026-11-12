import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'labels.dart';

class ToolPageFrame extends StatelessWidget {
  const ToolPageFrame({
    super.key,
    required this.title,
    required this.children,
    this.actions = const [],
    this.slivers = const [],
  });

  final String title;
  final List<Widget> children;
  final List<IconButtonData> actions;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) => Scaffold(
    title: title,
    iconActions: actions,
    body: Builder(
      builder: (context) => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, context.sectionsTopPadding, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          ...slivers,
          SliverToBoxAdapter(child: SizedBox(height: 24 + context.bottomInset)),
        ],
      ),
    ),
  );
}

class ToolField extends StatelessWidget {
  const ToolField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.multiline = false,
    this.secret = false,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool multiline;
  final bool secret;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(label, style: AppTextStyle.subheadline.of(context)),
        ),
        TextField(
          controller: controller,
          autocorrect: false,
          obscureText: secret,
          maxLines: multiline ? null : 1,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: onSubmitted,
        ),
      ],
    ),
  );
}

class ToolMessage extends StatelessWidget {
  const ToolMessage(this.message, {super.key, this.error = false});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
    child: Text(
      message,
      style: AppTextStyle.footnote
          .of(context)
          .copyWith(
            color: error
                ? context.colorScheme.error
                : context.colorScheme.onSurfaceVariant,
          ),
    ),
  );
}

class ToolRunButton extends StatelessWidget {
  const ToolRunButton({
    super.key,
    required this.busy,
    required this.onRun,
    this.onCancel,
    this.label,
  });

  final bool busy;
  final VoidCallback? onRun;
  final VoidCallback? onCancel;
  final String? label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: FilledButton(
      onPressed: busy ? onCancel : onRun,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy) ...[
            const SizedBox.square(dimension: 18, child: ActivityIndicator()),
            const SizedBox(width: 10),
          ],
          Text(
            busy
                ? context.appLocalizations.cancel
                : label ?? context.appLocalizations.speedTestStart,
          ),
        ],
      ),
    ),
  );
}

String toolValue(Object? value) {
  if (value == null || value == '') return '—';
  if (value is double) return value.toStringAsFixed(value.abs() < 1 ? 3 : 2);
  if (value is List) return '${value.length}';
  if (value is Map) {
    return [
      value['name'] ?? value['target'] ?? value['domain'] ?? value['address'],
      value['data'] ?? value['type'] ?? value['status'] ?? value['phase'],
    ].where((v) => v != null && v != '').join(' · ');
  }
  return '$value';
}

String toolMeasuredValue(String key, Object? value) {
  if (value is! num) return toolValue(value);
  if (['download', 'upload', 'speed', 'bitrate'].contains(key)) {
    return '${(value / 1000000).toStringAsFixed(2)} Mbps';
  }
  if (['up', 'down', 'bytes', 'proxy-up', 'proxy-down'].contains(key)) {
    return '${(value / 1048576).toStringAsFixed(2)} MiB';
  }
  if ([
    'latency',
    'jitter',
    'rtt',
    'resolve-time',
    'match-time',
    'download-latency',
    'upload-latency',
  ].contains(key)) {
    return '${value.toStringAsFixed(2)} ms';
  }
  if (key == 'packet-loss' || key == 'progress') {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
  return toolValue(value);
}

class ToolResultView extends StatelessWidget {
  const ToolResultView({
    super.key,
    required this.title,
    required this.value,
    this.onEntry,
  });

  final String title;
  final Object? value;
  final void Function(Map<String, Object?>)? onEntry;

  @override
  Widget build(BuildContext context) => ToolPageFrame(
    title: title,
    actions: [toolCopyAction(context, value)],
    slivers: [ToolResultSliver(value: value, onEntry: onEntry)],
    children: const [],
  );
}

IconButtonData toolCopyAction(BuildContext context, Object? value) =>
    IconButtonData(
      glyph: AppGlyphs.copy,
      tooltip: context.appLocalizations.copy,
      onPressed: value == null
          ? null
          : () => Clipboard.setData(
              ClipboardData(
                text: value is String
                    ? value
                    : const JsonEncoder.withIndent('  ').convert(value),
              ),
            ),
    );

class ToolResultSliver extends StatelessWidget {
  const ToolResultSliver({super.key, required this.value, this.onEntry});

  final Object? value;
  final void Function(Map<String, Object?>)? onEntry;

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    final entries = value is Map
        ? value.entries.map((e) => ('${e.key}', e.value)).toList()
        : value is List
        ? value.indexed.map((e) => ('${e.$1 + 1}', e.$2)).toList()
        : [(context.appLocalizations.ageOutput, value)];
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final (key, item) = entries[index];
          final nested = item is List || item is Map;
          final label = toolFieldLabel(context.appLocalizations, key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              radius: AppCorner.xl,
              onPressed: nested
                  ? () {
                      if (onEntry != null &&
                          item is Map &&
                          item['file'] is String) {
                        onEntry!(Map<String, Object?>.from(item));
                      } else {
                        BaseNavigator.push(
                          context,
                          ToolResultView(
                            title: label,
                            value: item,
                            onEntry: onEntry,
                          ),
                        );
                      }
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(label, style: AppTextStyle.subheadline.of(context)),
                    const SizedBox(height: 6),
                    if (nested)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              toolValue(item),
                              style: AppTextStyle.body.of(context),
                            ),
                          ),
                          const GlyphIcon(AppGlyphs.chevronForward, size: 18),
                        ],
                      )
                    else
                      SelectableText(
                        item is bool
                            ? item
                                  ? context.appLocalizations.tbEnabled
                                  : context.appLocalizations.tbDisabled
                            : toolMeasuredValue(key, item),
                        style: AppTextStyle.body.of(context),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
