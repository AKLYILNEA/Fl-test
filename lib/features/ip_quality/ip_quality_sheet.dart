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
  bool _retrying = false;

  Future<void> _editIp() async {
    final l = context.appLocalizations;
    final value = await showFloatingDialog<String>(
      context: context,
      child: InputDialog(
        title: l.ipRiskHint,
        value: ref.read(appSettingProvider).hideIp ? '' : _ip,
        validator: (v) => publicIpOf(v ?? '') == null ? l.ipRiskInvalid : null,
      ),
    );
    if (!mounted || value == null) return;
    final ip = publicIpOf(value);
    if (ip != null && ip != _ip) {
      setState(() {
        _ip = ip;
        _retrying = false;
      });
    }
  }

  void _retry() {
    setState(() => _retrying = true);
    ref.invalidate(ipRiskProvider(_ip));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final state = ref.watch(ipRiskProvider(_ip));
    final isLoading = state.isLoading && !state.hasValue;
    final risk = state.hasError ? null : state.value;
    final hidden = ref.watch(appSettingProvider.select((s) => s.hideIp));
    return Theme(
      data: Theme.of(context).copyWith(visualDensity: VisualDensity.standard),
      child: Scaffold(
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
        body: Builder(
          builder: (context) => NullStatusSwitcher(
            key: ValueKey(_ip),
            isLoading: !_retrying && isLoading,
            holdsArrival: false,
            loadingStatus: const Center(child: ActivityIndicator.page()),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                context.contentTopPadding + 12,
                16,
                20 + context.bottomInset,
              ),
              children: [
                Card(
                  radius: AppCorner.xl,
                  child: ListItem(
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
                              : AppTextStyle.headline.of(
                                  context,
                                  emphasized: true,
                                ),
                        ),
                      ],
                    ),
                    trailing: MinIconButtonTheme(
                      child: IconButton(
                        tooltip: l.edit,
                        onPressed: _editIp,
                        icon: const GlyphIcon(AppGlyphs.edit, size: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: context.motionDuration(commonDuration),
                  reverseDuration: context.motionDuration(
                    const Duration(milliseconds: 150),
                  ),
                  switchInCurve: Easing.emphasizedDecelerate,
                  switchOutCurve: Curves.easeIn,
                  layoutBuilder: (currentChild, previousChildren) => Align(
                    alignment: Alignment.topCenter,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[...previousChildren, ?currentChild],
                    ),
                  ),
                  transitionBuilder: (child, animation) => ActivityPresence(
                    animation: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: animation.drive(Tween(begin: 0.92, end: 1.0)),
                        child: child,
                      ),
                    ),
                  ),
                  child: _buildBody(
                    context,
                    isLoading: isLoading,
                    risk: risk,
                    hidden: hidden,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required bool isLoading,
    required IpRisk? risk,
    required bool hidden,
  }) {
    final l = context.appLocalizations;
    if (isLoading) {
      return const SizedBox(
        key: ValueKey('loading'),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: ActivityIndicator.page()),
        ),
      );
    }
    if (risk != null) {
      return Column(
        key: const ValueKey('data'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RiskScoreCard(risk: risk),
          const SizedBox(height: 12),
          if (risk.checks.isNotEmpty) ...[
            RiskChecksCard(risk: risk),
            const SizedBox(height: 12),
          ],
          _LocationCard(risk: risk, hidden: hidden),
          ListFooter(text: '${l.ipRiskSource} Scamalytics'),
        ],
      );
    }
    return SizedBox(
      key: const ValueKey('error'),
      width: double.infinity,
      child: Card(
        radius: AppCorner.xl,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlyphIcon(
              AppGlyphs.error,
              size: 28,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              l.ipRiskFailed,
              textAlign: TextAlign.center,
              style: AppTextStyle.body
                  .of(context)
                  .copyWith(color: context.colorScheme.error),
            ),
            const SizedBox(height: 16),
            TonalButton(
              size: TonalButtonSize.section,
              glyph: AppGlyphs.refresh,
              label: l.retry,
              onPressed: _retry,
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
      if (!hidden && risk.hostname.isNotEmpty)
        _value(context, l.ipRiskHostname, risk.hostname),
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
