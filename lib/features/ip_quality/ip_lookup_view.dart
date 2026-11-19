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
      dialogs.showBanner(
        context.appLocalizations.ipRiskInvalid,
        level: BannerLevel.error,
      );
      return;
    }
    _focusNode.unfocus();
    setState(() {
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
              final horizontalHero = heroCardWidth - 40 >= 380;
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
                    showOutboundShortcut: isCustom,
                    isWide: constraints.maxWidth >= 600,
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
        isWide: isWide,
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
            _IpFlagsCard(risk: risk, isWide: isWide),
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
    required this.showOutboundShortcut,
    required this.isWide,
    required this.onSubmitted,
    required this.onUseOutbound,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showOutboundShortcut;
  final bool isWide;
  final VoidCallback onSubmitted;
  final VoidCallback onUseOutbound;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
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
    final isDark = cs.brightness == Brightness.dark;
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

    final scoreBlock = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${risk.displayScore}',
          maxLines: 1,
          style: AppTextStyle.display
              .of(context, emphasized: true)
              .toTabular
              .copyWith(
                fontSize: horizontalHero ? 52 : 46,
                height: 1.0,
                color: scoreColor,
              ),
        ),
        const SizedBox(width: 5),
        Text(
          '/ 100',
          maxLines: 1,
          style: AppTextStyle.callout
              .of(context, emphasized: true)
              .toTabular
              .copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );

    final ipColumn = Column(
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
                  color: riskGradient.first.withValues(alpha: 0.13),
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
                      ? AppTextStyle.title2
                            .of(context, emphasized: true)
                            .toJetBrainsMono
                            .copyWith(color: cs.success)
                      : AppTextStyle.title2
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
        const SizedBox(height: 10),
        Wrap(
          spacing: 18,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _InlineMetric(
              dotColor: typeColor,
              label: l.ipType,
              value: typeText,
              valueColor: risk.isHomeBroadband ? riskGradient.first : null,
            ),
            _InlineMetric(
              dotColor: flagColor,
              label: l.ipFlags,
              value: totalChecks == 0 ? '\u2014' : '$hitCount / $totalChecks',
              valueColor: totalChecks == 0 ? null : flagColor,
              tabular: true,
            ),
          ],
        ),
      ],
    );

    final mainBody = horizontalHero
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: scoreBlock),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: Divider.separatorThicknessOf(context),
                    child: ColoredBox(color: Divider.colorOf(context)),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: ipColumn,
                  ),
                ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              scoreBlock,
              const SizedBox(height: 14),
              Divider(
                height: 1,
                thickness: Divider.separatorThicknessOf(context),
              ),
              const SizedBox(height: 14),
              ipColumn,
            ],
          );

    final riskScale = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${l.ipRiskScore} ${risk.displayScore} / 100',
          child: SizedBox(
            height: 24,
            width: double.infinity,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: risk.displayScore.toDouble()),
              duration: context.motionDuration(
                const Duration(milliseconds: 520),
              ),
              curve: Curves.easeOutCubic,
              builder: (_, animatedScore, _) => CustomPaint(
                painter: _RiskScaleBarPainter(
                  score: animatedScore,
                  surface: colors.card,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.ipRiskLow,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: cs.onSurfaceVariant),
            ),
            Text(
              l.ipRiskHigh,
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );

    return Card(
      radius: AppCorner.xl,
      padding: EdgeInsets.zero,
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: AppShape.xl,
          textDirection: Directionality.of(context),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.88, -1.15),
                      radius: 1.05,
                      colors: [
                        scoreColor.withValues(alpha: isDark ? 0.16 : 0.13),
                        scoreColor.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.72],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: fillHeight
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 18),
                  mainBody,
                  const SizedBox(height: 18),
                  riskScale,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({
    required this.dotColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.tabular = false,
  });

  final Color dotColor;
  final String label;
  final String value;
  final Color? valueColor;
  final bool tabular;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    var valueStyle = AppTextStyle.footnote
        .of(context, emphasized: true)
        .copyWith(color: valueColor ?? cs.onSurface);
    if (tabular) {
      valueStyle = valueStyle.toTabular;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        DecoratedBox(
          decoration: ShapeDecoration(color: dotColor, shape: AppShape.circle),
          child: const SizedBox.square(dimension: 7),
        ),
        Text(
          label,
          style: AppTextStyle.footnote
              .of(context)
              .copyWith(color: cs.onSurfaceVariant),
        ),
        Text(value, style: valueStyle),
      ],
    );
  }
}

class _RiskScaleBarPainter extends CustomPainter {
  const _RiskScaleBarPainter({required this.score, required this.surface});

  final double score;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 8, size.width, 8);
    final clamped = score.clamp(0.0, 100.0);
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(rect, AppRadius.full.topLeft),
      Paint()
        ..shader = LinearGradient(
          colors: riskGradient.map((c) => c.withValues(alpha: .24)).toList(),
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        rect.left,
        0,
        rect.left + rect.width * clamped / 100,
        size.height,
      ),
    );
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(rect, AppRadius.full.topLeft),
      Paint()
        ..shader = const LinearGradient(colors: riskGradient).createShader(rect),
    );
    canvas.restore();
    final center = Offset(
      (rect.width * clamped / 100).clamp(8.0, math.max(8.0, size.width - 8.0)),
      12,
    );
    canvas.drawCircle(
      center,
      8,
      Paint()..color = riskScoreColor(clamped.round()),
    );
    canvas.drawCircle(center, 4, Paint()..color = surface);
  }

  @override
  bool shouldRepaint(_RiskScaleBarPainter oldDelegate) =>
      score != oldDelegate.score || surface != oldDelegate.surface;
}

class _IpAttributionCard extends StatelessWidget {
  const _IpAttributionCard({
    required this.risk,
    required this.attribution,
    required this.hidden,
    required this.isWide,
  });

  final IpRisk risk;
  final IpLocateInfo attribution;
  final bool hidden;
  final bool isWide;

  Widget _field(
    BuildContext context,
    String label,
    String value, {
    bool mono = false,
  }) {
    final cs = context.colorScheme;
    final baseStyle = AppTextStyle.subheadline.of(context, emphasized: true);
    return Column(
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
    );
  }

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
    final showNetwork = network.isNotEmpty && network != company;
    final showHostname = !hidden && risk.hostname.isNotEmpty;

    final sections = <Widget>[
      if (hasLocation)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
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
        ),
      if (company.isNotEmpty && showNetwork)
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 13, child: _field(context, l.isp, company)),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 10,
                    child: _field(context, l.ipRiskAsn, network),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(context, l.isp, company),
                  const SizedBox(height: 12),
                  _field(context, l.ipRiskAsn, network),
                ],
              )
      else if (company.isNotEmpty)
        _field(context, l.isp, company)
      else if (showNetwork)
        _field(context, l.ipRiskAsn, network),
      if (showHostname)
        _field(context, l.ipRiskHostname, risk.hostname, mono: true),
    ];

    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _IpHeaderIconBadge(glyph: AppGlyphs.location, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  country.isNotEmpty || !hasLocation
                      ? l.ipRiskLocation
                      : l.ipRiskCity,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.headline.of(context, emphasized: true),
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
          if (sections.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final (index, section) in sections.indexed) ...[
              if (index > 0) ...[
                const SizedBox(height: 14),
                Divider(
                  height: 1,
                  thickness: Divider.separatorThicknessOf(context),
                ),
                const SizedBox(height: 14),
              ],
              section,
            ],
          ],
        ],
      ),
    );
  }
}

class _IpFlagsCard extends StatelessWidget {
  const _IpFlagsCard({required this.risk, required this.isWide});

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

    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _IpHeaderIconBadge(glyph: AppGlyphs.target, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.ipFlags,
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
          for (final (index, group) in groups.indexed) ...[
            if (index > 0) ...[
              const SizedBox(height: 13),
              Divider(
                height: 1,
                thickness: Divider.separatorThicknessOf(context),
              ),
              const SizedBox(height: 13),
            ],
            _FlagGroupRow(
              title: switch (group) {
                IpRiskGroup.datacenter => l.ipRiskHostingOrProxy,
                IpRiskGroup.blacklist => l.ipRiskBlacklist,
                IpRiskGroup.proxy => l.ipRiskProxyType,
              },
              checks: risk.checks.where((c) => c.group == group).toList(),
              homeBroadband:
                  risk.isHomeBroadband && group == IpRiskGroup.datacenter,
              isWide: isWide,
            ),
          ],
        ],
      ),
    );
  }
}

class _FlagGroupRow extends StatelessWidget {
  const _FlagGroupRow({
    required this.title,
    required this.checks,
    required this.homeBroadband,
    required this.isWide,
  });

  final String title;
  final List<IpRiskCheck> checks;
  final bool homeBroadband;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final groupHits = checks.where((c) => c.hit == true).length;
    final countText = Text(
      '$groupHits/${checks.length}',
      textAlign: TextAlign.end,
      style: AppTextStyle.caption1
          .of(context, emphasized: groupHits > 0)
          .toTabular
          .copyWith(
            color: groupHits > 0
                ? cs.error
                : cs.onSurfaceVariant.withValues(alpha: 0.78),
          ),
    );
    final labelText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyle.footnote
          .of(context, emphasized: true)
          .copyWith(color: cs.onSurfaceVariant),
    );
    final pills = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (homeBroadband)
          const _LookupFlagPill(
            check: IpRiskCheck(
              group: IpRiskGroup.datacenter,
              name: 'Home Broadband',
              hit: false,
            ),
            home: true,
          )
        else
          for (final check in checks) _LookupFlagPill(check: check),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 124, child: labelText),
          const SizedBox(width: 16),
          Expanded(child: pills),
          const SizedBox(width: 14),
          SizedBox(width: 40, child: countText),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: labelText),
            const SizedBox(width: 8),
            countText,
          ],
        ),
        const SizedBox(height: 10),
        pills,
      ],
    );
  }
}

class _LookupFlagPill extends StatelessWidget {
  const _LookupFlagPill({required this.check, this.home = false});

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
        color: hit || home ? color.withValues(alpha: 0.12) : colors.tone,
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
