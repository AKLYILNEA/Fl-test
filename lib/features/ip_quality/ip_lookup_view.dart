import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/ip.dart';
import 'package:fl_clash/common/service_probe.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/outbound_ip.dart';
import 'package:fl_clash/providers/routed_probe.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/dashboard/style.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ip_locate.dart';
import 'risk_model.dart';
import 'risk_provider.dart';
import 'risk_view.dart';

class IpLookupView extends ConsumerStatefulWidget {
  const IpLookupView({super.key, this.initialIp = ''});

  final String initialIp;

  @override
  ConsumerState<IpLookupView> createState() => _IpLookupViewState();
}

class _IpLookupViewState extends ConsumerState<IpLookupView> {
  late final OutboundIpProbe _probe;
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  String? _queriedIp;
  String? _inputError;
  bool _retrying = false;
  bool _retryHold = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _probe = ref.read(outboundIpProbeProvider.notifier)..watch(routedOutbound);
    final initial = publicIpOf(widget.initialIp);
    _queriedIp = initial;
    _controller = TextEditingController(text: initial ?? '');
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _probe.unwatch(routedOutbound);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final parsed = publicIpOf(_controller.text);
    if (parsed == null) {
      setState(() => _inputError = context.appLocalizations.ipRiskInvalid);
      return;
    }
    _focusNode.unfocus();
    setState(() {
      _inputError = null;
      _queriedIp = parsed;
      _retrying = false;
    });
    if (_controller.text.trim() != parsed) {
      _controller.value = TextEditingValue(
        text: parsed,
        selection: TextSelection.collapsed(offset: parsed.length),
      );
    }
  }

  void _useOutboundIp() {
    _focusNode.unfocus();
    _controller.clear();
    setState(() {
      _inputError = null;
      _queriedIp = null;
      _retrying = false;
    });
  }

  void _startRetryHold() {
    _retryTimer?.cancel();
    setState(() => _retryHold = true);
    _retryTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _retryHold = false);
    });
  }

  void _refresh(String activeIp) {
    if (_retryHold) return;
    _startRetryHold();
    setState(() => _retrying = false);
    if (_queriedIp == null) {
      _probe.refresh(const [routedOutbound]);
    }
    if (activeIp.isNotEmpty) {
      refreshIpRisk(ref, activeIp);
      ref.invalidate(ipLocateProvider(activeIp));
    }
  }

  void _retryFailed(
    String activeIp, {
    required bool riskFailed,
    required bool attributionFailed,
  }) {
    if (_retryHold) return;
    _startRetryHold();
    setState(() => _retrying = true);
    if (activeIp.isEmpty) {
      _probe.refresh(const [routedOutbound]);
      return;
    }
    if (riskFailed || (!riskFailed && !attributionFailed)) {
      refreshIpRisk(ref, activeIp);
    }
    if (attributionFailed) {
      ref.invalidate(ipLocateProvider(activeIp));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final entry = ref.watch(
      outboundIpProbeProvider.select((s) => s.entryOf(routedOutbound)),
    );
    final outboundIp = entry.value?.ip ?? '';
    final activeIp = _queriedIp ?? outboundIp;
    final isOutbound =
        activeIp.isNotEmpty &&
        (_queriedIp == null || _queriedIp == outboundIp);
    final isCustom =
        _queriedIp != null &&
        outboundIp.isNotEmpty &&
        _queriedIp != outboundIp;

    final probingOutbound =
        _queriedIp == null &&
        outboundIp.isEmpty &&
        (entry.phase == ProbePhase.probing || entry.phase == ProbePhase.empty);
    final outboundFailed =
        _queriedIp == null &&
        outboundIp.isEmpty &&
        entry.phase == ProbePhase.failed;

    final riskState = activeIp.isNotEmpty
        ? ref.watch(ipRiskProvider(activeIp))
        : null;
    final locateState = activeIp.isNotEmpty
        ? ref.watch(ipLocateProvider(activeIp))
        : null;

    final risk = riskState == null || riskState.hasError
        ? null
        : riskState.value;
    final attribution = locateState == null || locateState.hasError
        ? null
        : locateState.value;

    final riskFailed = riskState != null && !riskState.isLoading && risk == null;
    final attributionFailed =
        locateState != null && !locateState.isLoading && attribution == null;

    final isLoading =
        probingOutbound ||
        (!riskFailed &&
            !attributionFailed &&
            ((riskState?.isLoading ?? false) ||
                (locateState?.isLoading ?? false)));

    final hidden = ref.watch(appSettingProvider.select((s) => s.hideIp));
    final canRefresh = !_retryHold && !isLoading;

    return Theme(
      data: Theme.of(context).copyWith(visualDensity: VisualDensity.standard),
      child: Scaffold(
        title: l.ipQuery,
        iconActions: [
          IconButtonData(
            glyph: hidden ? AppGlyphs.eyeOff : AppGlyphs.eye,
            tooltip: l.hideIp,
            onPressed: () => ref
                .read(appSettingProvider.notifier)
                .update((s) => s.copyWith(hideIp: !hidden)),
          ),
          IconButtonData(
            glyph: AppGlyphs.refresh,
            tooltip: l.trafficStatsRefresh,
            onPressed: canRefresh ? () => _refresh(activeIp) : null,
          ),
        ],
        body: Builder(
          builder: (context) => LayoutBuilder(
            builder: (context, constraints) {
              const sidePadding = 16.0;
              final isWide = constraints.maxWidth >= 760;
              final contentWidth = constraints.maxWidth - sidePadding * 2;
              final heroCardWidth = isWide
                  ? (contentWidth - 12) * 0.6
                  : contentWidth;
              final horizontalHero = heroCardWidth - 40 >= 360;
              return ListView(
                padding: EdgeInsets.fromLTRB(
                  sidePadding,
                  context.contentTopPadding,
                  sidePadding,
                  24 + context.bottomInset,
                ),
                children: [
                  _IpSearchBar(
                    controller: _controller,
                    focusNode: _focusNode,
                    errorText: _inputError,
                    showOutboundShortcut: isCustom,
                    isWide: constraints.maxWidth >= 600,
                    onChanged: (_) {
                      if (_inputError != null) {
                        setState(() => _inputError = null);
                      }
                    },
                    onSubmitted: _submitSearch,
                    onUseOutbound: _useOutboundIp,
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: context.motionDuration(commonDuration),
                    reverseDuration: context.motionDuration(
                      const Duration(milliseconds: 160),
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
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child.key is ValueKey<String> &&
                              (child.key as ValueKey<String>).value.startsWith(
                                'data:',
                              )
                          ? ScaleTransition(
                              scale: animation.drive(
                                Tween(begin: 0.96, end: 1.0),
                              ),
                              child: child,
                            )
                          : child,
                    ),
                    child: _buildContent(
                      context,
                      isWide: isWide,
                      horizontalHero: horizontalHero,
                      activeIp: activeIp,
                      isOutbound: isOutbound,
                      hidden: hidden,
                      isLoading: isLoading,
                      outboundFailed: outboundFailed,
                      risk: risk,
                      attribution: attribution,
                      onRetry: () => _retryFailed(
                        activeIp,
                        riskFailed: riskFailed,
                        attributionFailed: attributionFailed,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required bool isWide,
    required bool horizontalHero,
    required String activeIp,
    required bool isOutbound,
    required bool hidden,
    required bool isLoading,
    required bool outboundFailed,
    required IpRisk? risk,
    required IpLocateInfo? attribution,
    required VoidCallback onRetry,
  }) {
    final l = context.appLocalizations;
    if (!_retrying && isLoading) {
      return SizedBox(
        key: ValueKey('loading:$activeIp'),
        height: 280,
        child: const Center(child: ActivityIndicator.page()),
      );
    }

    if (!isLoading && risk != null && attribution != null) {
      final heroCard = _IpRiskHeroCard(
        ip: activeIp,
        risk: risk,
        hidden: hidden,
        isOutbound: isOutbound,
        horizontalHero: horizontalHero,
        fillHeight: isWide,
      );
      final attributionCard = _IpAttributionCard(
        risk: risk,
        attribution: attribution,
        hidden: hidden,
        fillHeight: isWide,
      );
      return Column(
        key: ValueKey('data:$activeIp'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isWide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 6, child: heroCard),
                  const SizedBox(width: 12),
                  Expanded(flex: 4, child: attributionCard),
                ],
              ),
            )
          else ...[
            heroCard,
            const SizedBox(height: 12),
            attributionCard,
          ],
          if (risk.checks.isNotEmpty) ...[
            const SizedBox(height: 12),
            _IpChecksMatrixCard(risk: risk, isWide: isWide),
          ],
          ListFooter(text: '${l.ipRiskSource} ${l.ipRiskSources}'),
        ],
      );
    }

    return _IpLookupErrorCard(
      key: ValueKey('error:$activeIp:$outboundFailed'),
      ip: activeIp,
      hidden: hidden,
      loading: isLoading || _retryHold,
      onRetry: onRetry,
    );
  }
}

class _IpHeaderIconBadge extends StatelessWidget {
  const _IpHeaderIconBadge({required this.glyph, required this.color});

  final Glyph glyph;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.12),
        shape: AppShape.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: GlyphIcon(glyph, size: 18, color: color),
      ),
    );
  }
}

class _IpSearchBar extends StatelessWidget {
  const _IpSearchBar({
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.showOutboundShortcut,
    required this.isWide,
    required this.onChanged,
    required this.onSubmitted,
    required this.onUseOutbound,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final bool showOutboundShortcut;
  final bool isWide;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onUseOutbound;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    final colors = DashboardColors.of(context);
    final shortcut = _OutboundShortcutPill(onPressed: onUseOutbound);
    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SearchField(
                  controller: controller,
                  focusNode: focusNode,
                  height: 42,
                  fill: colors.tone,
                  hintText: l.ipRiskHint,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 42,
                child: isWide
                    ? FilledButton.icon(
                        onPressed: onSubmitted,
                        icon: const GlyphIcon(AppGlyphs.search, size: 17),
                        label: Text(l.search),
                      )
                    : FilledButton(
                        onPressed: onSubmitted,
                        child: Text(l.search),
                      ),
              ),
              if (isWide && showOutboundShortcut) ...[
                const SizedBox(width: 8),
                shortcut,
              ],
            ],
          ),
          if (!isWide && showOutboundShortcut) ...[
            const SizedBox(height: 8),
            Align(alignment: AlignmentDirectional.centerStart, child: shortcut),
          ],
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  GlyphIcon(AppGlyphs.error, size: 15, color: cs.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errorText!,
                      style: AppTextStyle.caption1
                          .of(context)
                          .copyWith(color: cs.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OutboundShortcutPill extends StatelessWidget {
  const _OutboundShortcutPill({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    final colors = DashboardColors.of(context);
    return PressRegion(
      onTap: onPressed,
      shape: AppShape.full,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: colors.tone, shape: AppShape.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              GlyphIcon(AppGlyphs.location, size: 15, color: cs.primary),
              Text(
                l.outboundIp,
                maxLines: 1,
                style: AppTextStyle.caption1
                    .of(context, emphasized: true)
                    .copyWith(color: cs.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IpRiskHeroCard extends StatelessWidget {
  const _IpRiskHeroCard({
    required this.ip,
    required this.risk,
    required this.hidden,
    required this.isOutbound,
    required this.horizontalHero,
    this.fillHeight = false,
  });

  final String ip;
  final IpRisk risk;
  final bool hidden;
  final bool isOutbound;
  final bool horizontalHero;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    final colors = DashboardColors.of(context);
    final scoreColor = riskScoreColor(risk.displayScore);
    final hitCount = risk.checks.where((c) => c.hit == true).length;
    final totalChecks = risk.checks.length;
    final typeText = risk.typeLabel(context) ?? risk.levelLabel(context);
    final typeColor = risk.isHomeBroadband ? riskGradient.first : scoreColor;
    final flagColor = totalChecks == 0
        ? cs.onSurfaceVariant
        : hitCount == 0
        ? riskGradient.first
        : cs.error;

    final header = Row(
      children: [
        _IpHeaderIconBadge(glyph: AppGlyphs.verified, color: scoreColor),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  l.ipRiskScore,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.headline.of(context, emphasized: true),
                ),
              ),
              const SizedBox(width: 2),
              MinIconButtonTheme(
                child: IconButton(
                  tooltip: l.ipRiskNoteTitle,
                  onPressed: () => dialogs.showAlert(
                    title: l.ipRiskNoteTitle,
                    message: riskNoteMessage(context, risk),
                  ),
                  icon: const GlyphIcon(AppGlyphs.info, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        RiskLevelBadge(risk: risk),
      ],
    );

    final ipIdentity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              l.ipAddress,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: cs.onSurfaceVariant),
            ),
            if (isOutbound) ...[
              const SizedBox(width: 8),
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: riskGradient.first.withValues(alpha: 0.12),
                  shape: AppShape.full,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      DecoratedBox(
                        decoration: ShapeDecoration(
                          color: riskGradient.first,
                          shape: AppShape.circle,
                        ),
                        child: const SizedBox.square(dimension: 6),
                      ),
                      Text(
                        l.outboundIp,
                        maxLines: 1,
                        style: AppTextStyle.caption2
                            .of(context, emphasized: true)
                            .copyWith(color: riskGradient.first),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  hidden ? '*****' : ip,
                  maxLines: 1,
                  style: hidden
                      ? AppTextStyle.title3
                            .of(context, emphasized: true)
                            .toJetBrainsMono
                            .copyWith(color: cs.success)
                      : AppTextStyle.title3
                            .of(context, emphasized: true)
                            .toTabular,
                ),
              ),
            ),
            const SizedBox(width: 4),
            MinIconButtonTheme(
              child: IconButton(
                tooltip: l.copy,
                onPressed: ip.isEmpty
                    ? null
                    : () => dialogs.copyToClipboard(context, ip),
                icon: const GlyphIcon(AppGlyphs.copy, size: 16),
              ),
            ),
          ],
        ),
      ],
    );

    final statBlocks = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _HeroMetricTile(
              label: l.ipType,
              value: typeText,
              dotColor: typeColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _HeroMetricTile(
              label: l.ipFlags,
              value: totalChecks == 0 ? '\u2014' : '$hitCount / $totalChecks',
              dotColor: flagColor,
              valueColor: totalChecks == 0 ? null : flagColor,
              tabular: true,
            ),
          ),
        ],
      ),
    );

    final gauge = _IpRiskArcGauge(
      score: risk.displayScore,
      scoreColor: scoreColor,
      trackColor: colors.track,
      surfaceColor: colors.card,
    );

    final body = horizontalHero
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              gauge,
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ipIdentity,
                    const SizedBox(height: 14),
                    statBlocks,
                  ],
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ipIdentity,
              const SizedBox(height: 14),
              Center(child: gauge),
              const SizedBox(height: 14),
              statBlocks,
            ],
          );

    final footer = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: Divider.separatorThicknessOf(context)),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              l.ipRiskLow,
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 14,
                child: CustomPaint(
                  painter: _MiniRiskBarPainter(
                    score: risk.displayScore,
                    surface: colors.card,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l.ipRiskHigh,
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );

    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: fillHeight
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 18),
          body,
          const SizedBox(height: 18),
          footer,
        ],
      ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({
    required this.label,
    required this.value,
    required this.dotColor,
    this.valueColor,
    this.tabular = false,
  });

  final String label;
  final String value;
  final Color dotColor;
  final Color? valueColor;
  final bool tabular;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final colors = DashboardColors.of(context);
    var valueStyle = AppTextStyle.subheadline
        .of(context, emphasized: true)
        .copyWith(color: valueColor ?? cs.onSurface);
    if (tabular) {
      valueStyle = valueStyle.toTabular;
    }
    return DecoratedBox(
      decoration: ShapeDecoration(color: colors.tone, shape: AppShape.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              spacing: 6,
              children: [
                DecoratedBox(
                  decoration: ShapeDecoration(
                    color: dotColor,
                    shape: AppShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 7),
                ),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.caption1
                        .of(context)
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(value, maxLines: 1, style: valueStyle),
            ),
          ],
        ),
      ),
    );
  }
}

class _IpRiskArcGauge extends StatelessWidget {
  const _IpRiskArcGauge({
    required this.score,
    required this.scoreColor,
    required this.trackColor,
    required this.surfaceColor,
  });

  final int score;
  final Color scoreColor;
  final Color trackColor;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final l = context.appLocalizations;
    final target = score.clamp(0, 100) / 100.0;
    return Semantics(
      label: '${l.ipRiskScore} $score / 100',
      child: MediaQuery.withNoTextScaling(
        child: SizedBox(
          width: 148,
          height: 130,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: target),
            duration: context.motionDuration(const Duration(milliseconds: 650)),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) => Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _IpRiskArcPainter(
                      progress: progress,
                      scoreColor: scoreColor,
                      trackColor: trackColor,
                      surfaceColor: surfaceColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        maxLines: 1,
                        style: AppTextStyle.display
                            .of(context, emphasized: true)
                            .toTabular
                            .copyWith(color: scoreColor, height: 1.0),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '/ 100',
                        maxLines: 1,
                        style: AppTextStyle.caption1
                            .of(context)
                            .toTabular
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 0,
                  child: Text(
                    '0',
                    style: AppTextStyle.caption2
                        .of(context)
                        .toTabular
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 0,
                  child: Text(
                    '100',
                    style: AppTextStyle.caption2
                        .of(context)
                        .toTabular
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IpRiskArcPainter extends CustomPainter {
  const _IpRiskArcPainter({
    required this.progress,
    required this.scoreColor,
    required this.trackColor,
    required this.surfaceColor,
  });

  final double progress;
  final Color scoreColor;
  final Color trackColor;
  final Color surfaceColor;

  static const _startAngle = math.pi * 145 / 180;
  static const _sweepAngle = math.pi * 250 / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 9.5;
    final radius = math.min(size.width, size.height) / 2 - stroke;
    final center = Offset(size.width / 2, size.height * 0.54);
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      math.max(0, radius - 12),
      Paint()..color = scoreColor.withValues(alpha: 0.08),
    );

    canvas.drawArc(
      rect,
      _startAngle,
      _sweepAngle,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );

    final clamped = progress.clamp(0.0, 1.0);
    final activeSweep = math.max(_sweepAngle * clamped, 0.02);
    const capPad = 0.14;
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: _sweepAngle + capPad * 2,
      colors: riskGradient,
      stops: const [0.05, 0.5, 0.95],
      transform: const GradientRotation(_startAngle - capPad),
    ).createShader(rect);

    canvas.drawArc(
      rect,
      _startAngle,
      activeSweep,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );

    final tipAngle = _startAngle + _sweepAngle * clamped;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    canvas.drawCircle(tip, 9.5, Paint()..color = scoreColor.withValues(alpha: 0.22));
    canvas.drawCircle(tip, 6.2, Paint()..color = scoreColor);
    canvas.drawCircle(tip, 3.0, Paint()..color = surfaceColor);
  }

  @override
  bool shouldRepaint(_IpRiskArcPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      scoreColor != oldDelegate.scoreColor ||
      trackColor != oldDelegate.trackColor ||
      surfaceColor != oldDelegate.surfaceColor;
}

class _MiniRiskBarPainter extends CustomPainter {
  const _MiniRiskBarPainter({required this.score, required this.surface});

  final int score;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, (size.height - 5) / 2, size.width, 5);
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(rect, AppRadius.full.topLeft),
      Paint()
        ..shader = LinearGradient(
          colors: riskGradient.map((c) => c.withValues(alpha: 0.28)).toList(),
        ).createShader(rect),
    );
    final fraction = score.clamp(0, 100) / 100.0;
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(rect.left, 0, rect.left + rect.width * fraction, size.height),
    );
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(rect, AppRadius.full.topLeft),
      Paint()
        ..shader = const LinearGradient(colors: riskGradient).createShader(rect),
    );
    canvas.restore();
    final center = Offset(
      (rect.width * fraction).clamp(5.5, math.max(5.5, size.width - 5.5)),
      size.height / 2,
    );
    canvas.drawCircle(center, 5.5, Paint()..color = riskScoreColor(score));
    canvas.drawCircle(center, 2.5, Paint()..color = surface);
  }

  @override
  bool shouldRepaint(_MiniRiskBarPainter oldDelegate) =>
      score != oldDelegate.score || surface != oldDelegate.surface;
}

class _IpAttributionCard extends StatelessWidget {
  const _IpAttributionCard({
    required this.risk,
    required this.attribution,
    required this.hidden,
    this.fillHeight = false,
  });

  final IpRisk risk;
  final IpLocateInfo attribution;
  final bool hidden;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    final colors = DashboardColors.of(context);
    final country = risk.countryLabel ?? '';
    final place = risk.placeLabel ?? '';
    final hasLocation = country.isNotEmpty || place.isNotEmpty;
    final info = attribution.ip == risk.ip ? attribution : null;
    final company = info?.company ?? '';
    final network = info?.network ?? '';
    final asn = info?.asn ?? '';
    final showHostname = !hidden && risk.hostname.isNotEmpty;

    final tiles = <Widget>[
      if (company.isNotEmpty) _AttributionTile(label: l.isp, value: company),
      if (network.isNotEmpty && network != company)
        _AttributionTile(label: l.ipRiskAsn, value: network),
      if (showHostname)
        _AttributionTile(
          label: l.ipRiskHostname,
          value: risk.hostname,
          mono: true,
        ),
    ];

    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: fillHeight
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _IpHeaderIconBadge(
                    glyph: AppGlyphs.location,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      country.isNotEmpty || !hasLocation
                          ? l.ipRiskLocation
                          : l.ipRiskCity,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.headline.of(
                        context,
                        emphasized: true,
                      ),
                    ),
                  ),
                  if (asn.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    DecoratedBox(
                      decoration: ShapeDecoration(
                        color: colors.tone,
                        shape: AppShape.full,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          asn,
                          style: AppTextStyle.footnote
                              .of(context, emphasized: true)
                              .toTabular
                              .copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (hasLocation) ...[
                const SizedBox(height: 16),
                if (country.isNotEmpty)
                  EmojiText(
                    country,
                    style: AppTextStyle.title2.of(context, emphasized: true),
                  ),
                if (place.isNotEmpty) ...[
                  SizedBox(height: country.isNotEmpty ? 4 : 0),
                  SelectableText(
                    place,
                    style: country.isNotEmpty
                        ? AppTextStyle.subheadline
                              .of(context)
                              .copyWith(color: cs.onSurfaceVariant)
                        : AppTextStyle.title3.of(context, emphasized: true),
                  ),
                ],
              ],
            ],
          ),
          if (tiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (index, tile) in tiles.indexed) ...[
                  if (index > 0) const SizedBox(height: 10),
                  tile,
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AttributionTile extends StatelessWidget {
  const _AttributionTile({
    required this.label,
    required this.value,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final colors = DashboardColors.of(context);
    final baseStyle = AppTextStyle.subheadline.of(context, emphasized: true);
    return DecoratedBox(
      decoration: ShapeDecoration(color: colors.tone, shape: AppShape.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyle.caption1
                  .of(context)
                  .copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            SelectableText(
              value,
              style: mono ? baseStyle.toJetBrainsMono : baseStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _IpChecksMatrixCard extends StatelessWidget {
  const _IpChecksMatrixCard({required this.risk, required this.isWide});

  final IpRisk risk;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    final groups = IpRiskGroup.values
        .where((group) => risk.checks.any((c) => c.group == group))
        .toList();
    if (groups.isEmpty) return const SizedBox.shrink();

    final hitCount = risk.checks.where((c) => c.hit == true).length;
    final totalCount = risk.checks.length;
    final summaryColor = hitCount > 0 ? cs.error : riskGradient.first;

    final groupWidgets = [
      for (final group in groups)
        _CheckGroupPanel(
          title: switch (group) {
            IpRiskGroup.datacenter => l.ipRiskHostingOrProxy,
            IpRiskGroup.blacklist => l.ipRiskBlacklist,
            IpRiskGroup.proxy => l.ipRiskProxyType,
          },
          checks: risk.checks.where((c) => c.group == group).toList(),
          homeBroadband:
              risk.isHomeBroadband && group == IpRiskGroup.datacenter,
        ),
    ];

    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _IpHeaderIconBadge(glyph: AppGlyphs.target, color: summaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.ipRiskCheck,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.headline.of(context, emphasized: true),
                ),
              ),
              const SizedBox(width: 12),
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: summaryColor.withValues(alpha: 0.12),
                  shape: AppShape.full,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      GlyphIcon(
                        hitCount > 0
                            ? AppGlyphs.error
                            : AppGlyphs.checkCircle,
                        size: 14,
                        color: summaryColor,
                      ),
                      Text(
                        '$hitCount / $totalCount',
                        style: AppTextStyle.caption1
                            .of(context, emphasized: true)
                            .toTabular
                            .copyWith(color: summaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isWide && groupWidgets.length > 1)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, panel) in groupWidgets.indexed) ...[
                    if (index > 0) const SizedBox(width: 12),
                    Expanded(child: panel),
                  ],
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, panel) in groupWidgets.indexed) ...[
                  if (index > 0) const SizedBox(height: 12),
                  panel,
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _CheckGroupPanel extends StatelessWidget {
  const _CheckGroupPanel({
    required this.title,
    required this.checks,
    required this.homeBroadband,
  });

  final String title;
  final List<IpRiskCheck> checks;
  final bool homeBroadband;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final colors = DashboardColors.of(context);
    final groupHits = checks.where((c) => c.hit == true).length;
    return DecoratedBox(
      decoration: ShapeDecoration(color: colors.tone, shape: AppShape.lg),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.footnote
                        .of(context, emphasized: true)
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$groupHits/${checks.length}',
                  style: AppTextStyle.caption2
                      .of(context, emphasized: groupHits > 0)
                      .toTabular
                      .copyWith(
                        color: groupHits > 0
                            ? cs.error
                            : cs.onSurfaceVariant.withValues(alpha: 0.78),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (homeBroadband)
                  const _MatrixCheckPill(
                    check: IpRiskCheck(
                      group: IpRiskGroup.datacenter,
                      name: 'Home Broadband',
                      hit: false,
                    ),
                    home: true,
                  )
                else
                  for (final check in checks) _MatrixCheckPill(check: check),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatrixCheckPill extends StatelessWidget {
  const _MatrixCheckPill({required this.check, this.home = false});

  final IpRiskCheck check;
  final bool home;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final colors = DashboardColors.of(context);
    final hit = check.hit == true;
    final color = home
        ? riskGradient.first
        : hit
        ? cs.error
        : cs.onSurfaceVariant;
    final leading = home
        ? GlyphIcon(AppGlyphs.checkCircle, size: 14, color: color)
        : hit
        ? GlyphIcon(AppGlyphs.error, size: 14, color: color)
        : check.hit == null
        ? GlyphIcon(AppGlyphs.helpCircle, size: 14, color: color)
        : DecoratedBox(
            decoration: ShapeDecoration(
              shape: AppShape.circle.copyWith(
                side: BorderSide(color: color, width: 1.4),
              ),
            ),
            child: const SizedBox.square(dimension: 12),
          );
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: hit || home ? color.withValues(alpha: 0.12) : colors.card,
        shape: AppShape.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          leading,
          Flexible(
            child: Text(
              home
                  ? context.appLocalizations.ipRiskHomeBroadband
                  : riskCheckLabel(context, check.name),
              style: AppTextStyle.caption1
                  .of(context, emphasized: hit || home)
                  .copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _IpLookupErrorCard extends StatelessWidget {
  const _IpLookupErrorCard({
    super.key,
    required this.ip,
    required this.hidden,
    required this.loading,
    required this.onRetry,
  });

  final String ip;
  final bool hidden;
  final bool loading;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final cs = context.colorScheme;
    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlyphIcon(AppGlyphs.error, size: 28, color: cs.error),
          const SizedBox(height: 12),
          if (ip.isNotEmpty) ...[
            Text(
              hidden ? '*****' : ip,
              textAlign: TextAlign.center,
              style: hidden
                  ? AppTextStyle.headline
                        .of(context, emphasized: true)
                        .toJetBrainsMono
                        .copyWith(color: cs.success)
                  : AppTextStyle.headline
                        .of(context, emphasized: true)
                        .toTabular,
            ),
            const SizedBox(height: 6),
          ],
          Text(
            l.ipRiskFailed,
            textAlign: TextAlign.center,
            style: AppTextStyle.body.of(context).copyWith(color: cs.error),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: FadeBox(
              child: loading
                  ? const SizedBox(
                      key: ValueKey('spinner'),
                      height: 48,
                      child: Center(child: ActivityIndicator(size: 20)),
                    )
                  : FilledButton.icon(
                      key: const ValueKey('retry'),
                      onPressed: onRetry,
                      icon: const GlyphIcon(AppGlyphs.refresh, size: 18),
                      label: Text(l.retry),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
