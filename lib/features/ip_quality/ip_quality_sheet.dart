import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/ip.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'risk_model.dart';
import 'risk_provider.dart';
import 'risk_view.dart';

Future<void> showIpQualitySheet(
  BuildContext context, {
  required String ip,
  bool outbound = true,
}) {
  Widget page(BuildContext context) => IpRiskSheet(ip: ip, outbound: outbound);
  if (isSheetPage(context)) {
    return Navigator.of(context).push(PagedSheetRoute(builder: page));
  }
  return showSheet<void>(context: context, builder: page);
}

class IpRiskSheet extends ConsumerStatefulWidget {
  const IpRiskSheet({super.key, required this.ip, this.outbound = true});
  final String ip;
  final bool outbound;

  @override
  ConsumerState<IpRiskSheet> createState() => _IpRiskSheetState();
}

class _IpRiskSheetState extends ConsumerState<IpRiskSheet> {
  late String _ip = widget.ip;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final state = ref.watch(ipRiskProvider(_ip));
    final risk = state.isLoading || state.hasError ? null : state.value;
    final hidden = ref.watch(appSettingProvider.select((s) => s.hideIp));
    return Scaffold(
      title: widget.outbound ? l.outboundIp : l.ipDetails,
      iconActions: [
        IconButtonData(
          glyph: hidden ? AppGlyphs.eyeOff : AppGlyphs.eye,
          tooltip: l.hideIp,
          onPressed: () => ref
              .read(appSettingProvider.notifier)
              .update((s) => s.copyWith(hideIp: !hidden)),
        ),
      ],
      actions: [
        AppBarActionButton(
          data: IconButtonData(
            glyph: AppGlyphs.refresh,
            tooltip: l.ipQualityRetry,
            onPressed: state.isLoading
                ? null
                : () => ref.invalidate(ipRiskProvider(_ip)),
          ),
          icon: _RiskRefreshIcon(loading: state.isLoading),
        ),
      ],
      body: Builder(
        builder: (context) => ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            context.contentTopPadding + 12,
            16,
            20 + context.bottomInset,
          ),
          children: [
            Card(
              radius: AppCorner.xl,
              child: ListItem.input(
                leading: const GlyphIcon(AppGlyphs.proxies),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.ipAddress,
                      style: AppTextStyle.footnote
                          .of(context)
                          .copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hidden ? '*****' : _ip,
                      style: hidden
                          ? AppTextStyle.headline
                                .of(context, emphasized: true)
                                .toJetBrainsMono
                          : AppTextStyle.headline.of(context, emphasized: true),
                    ),
                  ],
                ),
                dialogTitle: l.ipRiskHint,
                value: hidden ? '*****' : _ip,
                validator: (v) =>
                    publicIpOf(v ?? '') == null ? l.ipRiskInvalid : null,
                onChanged: (v) {
                  if (v != null && publicIpOf(v) != null) {
                    setState(() => _ip = publicIpOf(v)!);
                  }
                },
                trailing: const GlyphIcon(AppGlyphs.edit, size: 16),
              ),
            ),
            const SizedBox(height: 12),
            if (risk != null) ...[
              RiskScoreCard(risk: risk),
              const SizedBox(height: 12),
              if (risk.checks.isNotEmpty) ...[
                RiskChecksCard(risk: risk),
                const SizedBox(height: 12),
              ],
              _LocationCard(risk: risk, hidden: hidden),
              const SizedBox(height: 16),
              Text(
                '${l.ipRiskSource} Scamalytics',
                textAlign: TextAlign.start,
                style: AppTextStyle.footnote
                    .of(context)
                    .copyWith(color: context.colorScheme.onSurfaceVariant),
              ),
            ] else if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: ActivityIndicator.page()),
              )
            else
              Card(
                radius: AppCorner.xl,
                padding: const EdgeInsets.all(24),
                child: Text(
                  l.ipRiskFailed,
                  style: AppTextStyle.body
                      .of(context)
                      .copyWith(color: context.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.risk, required this.hidden});
  final IpRisk risk;
  final bool hidden;

  Widget _value(
    BuildContext context,
    String title,
    String value, {
    bool emoji = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        title,
        style: AppTextStyle.footnote
            .of(context)
            .copyWith(color: context.colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 6),
      if (emoji)
        EmojiText(value, style: AppTextStyle.body.of(context, emphasized: true))
      else
        SelectableText(
          value,
          style: hidden && value.contains('*****')
              ? AppTextStyle.body.of(context, emphasized: true).toJetBrainsMono
              : AppTextStyle.body.of(context, emphasized: true),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final country = [
      if (risk.countryCode.isNotEmpty) risk.countryCode.countryFlagEmoji,
      risk.country.isNotEmpty ? risk.country : risk.countryCode,
    ].where((s) => s.isNotEmpty).join(' ');
    final place = [
      risk.region,
      risk.city,
    ].where((s) => s.isNotEmpty).toSet().join(' · ');
    final owner = [
      risk.organization,
      risk.asn,
    ].where((s) => s.isNotEmpty).join(' · ');
    final rows = <Widget>[
      if (country.isNotEmpty || place.isNotEmpty)
        LayoutBuilder(
          builder: (context, constraints) {
            final a = _value(context, l.ipRiskLocation, country, emoji: true);
            final b = _value(context, l.ipRiskCity, place);
            if (country.isEmpty) return b;
            if (place.isEmpty) return a;
            if (constraints.maxWidth < 320 ||
                MediaQuery.textScalerOf(context).scale(16) > 22) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [a, const SizedBox(height: 18), b],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: a),
                const SizedBox(width: 20),
                Expanded(child: b),
              ],
            );
          },
        ),
      if (owner.isNotEmpty) _value(context, l.operatorOrAsn, owner),
      if (risk.isp.isNotEmpty && risk.isp != risk.organization)
        _value(context, l.isp, risk.isp),
      if (risk.hostname.isNotEmpty)
        _value(
          context,
          l.ipRiskHostname,
          hidden
              ? risk.hostname.replaceAll(
                  RegExp(RegExp.escape(risk.ip), caseSensitive: false),
                  '*****',
                )
              : risk.hostname,
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, row) in rows.indexed) ...[
            if (index > 0) const SizedBox(height: 20),
            row,
          ],
        ],
      ),
    );
  }
}

class _RiskRefreshIcon extends StatefulWidget {
  const _RiskRefreshIcon({required this.loading});
  final bool loading;

  @override
  State<_RiskRefreshIcon> createState() => _RiskRefreshIconState();
}

class _RiskRefreshIconState extends State<_RiskRefreshIcon>
    with SingleTickerProviderStateMixin {
  late final _turns = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  void _sync() {
    if (widget.loading && !MediaQuery.disableAnimationsOf(context)) {
      if (!_turns.isAnimating) {
        _turns.repeat();
      }
    } else {
      _turns.reset();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _RiskRefreshIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: _turns,
    child: GlyphIcon(
      AppGlyphs.refresh,
      color: widget.loading ? context.colorScheme.onSurface : null,
    ),
  );
}
