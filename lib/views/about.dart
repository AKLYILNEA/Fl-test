import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/about/miuix_bg_effect.dart';
import 'package:fl_clash/features/about/miuix_frosted_card.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Contributor {
  final String avatar;
  final String name;

  /// Says this is the fork's own build rather than an icon credit.
  final bool secondaryDevelopment;

  const Contributor({
    required this.avatar,
    required this.name,
    this.secondaryDevelopment = false,
  });
}

class AboutView extends ConsumerStatefulWidget {
  const AboutView({super.key, this.dynamicBackground = true});

  final bool dynamicBackground;

  @override
  ConsumerState<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends ConsumerState<AboutView>
    with SingleTickerProviderStateMixin {
  static const _contributors = [
    Contributor(
      avatar: 'assets/images/avatar/aaANDkk.jpg',
      name: 'aaANDkk',
      secondaryDevelopment: true,
    ),
    Contributor(avatar: 'assets/images/avatar/june2.jpg', name: 'June2'),
    Contributor(avatar: 'assets/images/avatar/arue.jpg', name: 'Arue'),
  ];

  final GlobalKey _backdropKey = GlobalKey();
  final GlobalKey _heroKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  late final MiuixBgEffectController _bgController = MiuixBgEffectController(
    vsync: this,
  );

  double _scrollOffset = 0.0;
  double _heroExtent = 280.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBgAnimation();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final next = math.max(0.0, _scrollController.offset);
    if ((next - _scrollOffset).abs() < 0.5 && _scrollProgress == 1.0 && next >= _heroExtent) {
      return;
    }
    setState(() {
      _scrollOffset = next;
    });
    _syncBgAnimation();
  }

  double get _scrollProgress =>
      (_heroExtent <= 0 ? 0.0 : (_scrollOffset / _heroExtent)).clamp(0.0, 1.0);

  void _syncBgAnimation() {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isWide = !context.isMobileView;
    final preset = MiuixBgConfig.of(isWide: isWide, isDark: isDark);
    final playing =
        widget.dynamicBackground &&
        !context.disableAnimations &&
        _scrollProgress < 1.0;
    _bgController.sync(
      playing: playing,
      colorInterpPeriod: preset.colorInterpPeriod,
    );
  }

  void _measureHero() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _heroKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.size.height > 0) {
        final extent = math.max(120.0, box.size.height);
        if ((extent - _heroExtent).abs() > 2.0) {
          setState(() {
            _heroExtent = extent;
          });
          _syncBgAnimation();
        }
      }
    });
  }

  Future<void> _checkUpdate(BuildContext context) async {
    if (ref.read(loadingProvider(LoadingTag.checkUpdate))) return;
    final commonAction = ref.read(commonActionProvider.notifier);
    final result = await globalState.loadingRun(
      () async => (release: await request.checkForUpdate()),
      title: context.appLocalizations.checkUpdate,
      tag: LoadingTag.checkUpdate,
    );
    if (result == null) return;
    unawaited(
      commonAction.checkUpdateResultHandle(data: result.release, isUser: true),
    );
  }

  Widget _buildLinkItem({
    required Glyph glyph,
    required String title,
    required String url,
    required String label,
  }) {
    return ListItem(
      leading: _LinkBadge(glyph: glyph),
      title: Text(title),
      subtitle: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const GlyphIcon(AppGlyphs.openExternal),
      onTap: () {
        dialogs.openUrl(url);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final isLoading = ref.watch(loadingProvider(LoadingTag.checkUpdate));
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final isWide = !context.isMobileView;
    final preset = MiuixBgConfig.of(isWide: isWide, isDark: isDark);
    final progress = _scrollProgress;
    final barTitleAlpha = ((progress - 0.35) / 0.65).clamp(0.0, 1.0);
    final collapsed = progress >= 1.0;

    _bgController.sync(
      playing:
          widget.dynamicBackground &&
          !context.disableAnimations &&
          !collapsed,
      colorInterpPeriod: preset.colorInterpPeriod,
    );
    _measureHero();

    final barBackgroundColor = SurfaceLevel.page
        .colorOf(colorScheme)
        .withValues(alpha: barTitleAlpha);

    return Scaffold(
      isLoading: isLoading,
      title: appLocalizations.about,
      titleWidget: Opacity(
        opacity: barTitleAlpha,
        child: Text(appLocalizations.about),
      ),
      backgroundColor: collapsed ? null : barBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: MiuixAboutBackdrop(
              backdropKey: _backdropKey,
              controller: _bgController,
              preset: preset,
              alpha: (1.0 - progress).clamp(0.0, 1.0),
            ),
          ),
          Positioned.fill(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(top: context.contentTopPadding),
                  sliver: SliverToBoxAdapter(
                    child: KeyedSubtree(
                      key: _heroKey,
                      child: Transform.translate(
                        offset: Offset(0, _scrollOffset * 0.65),
                        child: _AboutHero(
                          backdropKey: _backdropKey,
                          controller: _bgController,
                          preset: preset,
                          scrollProgress: progress,
                          isCheckingUpdate: isLoading,
                          onCheckUpdate: () {
                            _checkUpdate(context);
                          },
                          onEnterDeveloperMode: () {
                            ref
                                .read(appSettingProvider.notifier)
                                .update(
                                  (state) =>
                                      state.copyWith(developerMode: true),
                                );
                            dialogs.showBanner(
                              appLocalizations.developerModeEnableTip,
                              level: BannerLevel.success,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      32 + context.bottomInset,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MiuixFrostedSection(
                          title: appLocalizations.more,
                          items: [
                            _buildLinkItem(
                              glyph: AppGlyphs.code,
                              title: appLocalizations.project,
                              url: 'https://github.com/aaANDkk/FlClash-Myui',
                              label: 'github.com/aaANDkk/FlClash-Myui',
                            ),
                            _buildLinkItem(
                              glyph: AppGlyphs.cpu,
                              title: appLocalizations.core,
                              url:
                                  'https://github.com/chen08209/Clash.Meta/tree/FlClash',
                              label: 'github.com/chen08209/Clash.Meta',
                            ),
                            _buildLinkItem(
                              glyph: AppGlyphs.send,
                              title: 'Telegram',
                              url: 'https://t.me/FlClash',
                              label: 't.me/FlClash',
                            ),
                          ],
                        ),
                        MiuixFrostedSection(
                          title: appLocalizations.otherContributors,
                          items: [
                            for (final contributor in _contributors)
                              ListItem(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  foregroundDecoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(contributor.avatar),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primaryContainer,
                                  ),
                                ),
                                title: Text(contributor.name),
                                subtitle: Text(
                                  contributor.secondaryDevelopment
                                      ? appLocalizations
                                          .secondaryDevelopmentBuild
                                      : appLocalizations.appIconDesign,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  final GlobalKey backdropKey;
  final MiuixBgEffectController controller;
  final MiuixBgConfig preset;
  final double scrollProgress;
  final bool isCheckingUpdate;
  final VoidCallback onCheckUpdate;
  final VoidCallback onEnterDeveloperMode;

  const _AboutHero({
    required this.backdropKey,
    required this.controller,
    required this.preset,
    required this.scrollProgress,
    required this.isCheckingUpdate,
    required this.onCheckUpdate,
    required this.onEnterDeveloperMode,
  });

  static const _logoSize = 88.0;
  static const _logoInset = 10.0;

  Widget _fadeScale(double progress, Widget child) {
    final clamped = progress.clamp(0.0, 1.0);
    return Opacity(
      opacity: 1.0 - clamped,
      child: Transform.scale(scale: 1.0 - clamped * 0.05, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appLocalizations = context.appLocalizations;
    final iconProgress = ((scrollProgress - 0.35) / 0.15).clamp(0.0, 1.0);
    final titleProgress = ((scrollProgress - 0.20) / 0.15).clamp(0.0, 1.0);
    final metaProgress = ((scrollProgress - 0.05) / 0.15).clamp(0.0, 1.0);
    final headlineStyle = AppTextStyle.title1
        .of(context, emphasized: true)
        .copyWith(fontSize: 35, fontWeight: FontWeight.w700, height: 1.18);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          _fadeScale(
            iconProgress,
            _DeveloperModeDetector(
              onEnterDeveloperMode: onEnterDeveloperMode,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: const Color(0xFFFFFFFF),
                  shape: AppShape.all(24),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(_logoInset),
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: _logoSize - _logoInset * 2,
                    height: _logoSize - _logoInset * 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _fadeScale(
            titleProgress,
            MiuixChromaticTitle(
              text: appName,
              style: headlineStyle,
              backdropKey: backdropKey,
              controller: controller,
              preset: preset,
            ),
          ),
          const SizedBox(height: 10),
          _fadeScale(
            metaProgress,
            Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _Pill(
                      label: 'v${globalState.packageInfo.version}',
                      color: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    _Pill(
                      label: 'GPL-3.0',
                      color: colorScheme.brightness == Brightness.dark
                          ? colorScheme.surfaceContainer.withValues(alpha: 0.72)
                          : const Color(0xB8FFFFFF),
                      foregroundColor: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(
                    appLocalizations.desc,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.subheadline
                        .of(context)
                        .copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                ),
                const SizedBox(height: 18),
                TonalButton(
                  size: TonalButtonSize.bar,
                  glyph: AppGlyphs.sync,
                  label: appLocalizations.checkUpdate,
                  onPressed: isCheckingUpdate ? null : onCheckUpdate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color foregroundColor;

  const _Pill({
    required this.label,
    required this.color,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(color: color, shape: AppShape.full),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          label,
          style: AppTextStyle.caption1
              .of(context, emphasized: true)
              .copyWith(color: foregroundColor),
        ),
      ),
    );
  }
}

class _LinkBadge extends StatelessWidget {
  final Glyph glyph;

  const _LinkBadge({required this.glyph});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
            : const Color(0x70FFFFFF),
        shape: AppShape.md,
      ),
      child: SizedBox.square(
        dimension: 40,
        child: Center(
          child: GlyphIcon(
            glyph,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _DeveloperModeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onEnterDeveloperMode;

  const _DeveloperModeDetector({
    required this.child,
    required this.onEnterDeveloperMode,
  });

  @override
  State<_DeveloperModeDetector> createState() => _DeveloperModeDetectorState();
}

class _DeveloperModeDetectorState extends State<_DeveloperModeDetector> {
  int _counter = 0;
  Timer? _timer;

  void _handleTap() {
    _counter++;
    if (_counter >= 5) {
      widget.onEnterDeveloperMode();
      _resetCounter();
    } else {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 1), _resetCounter);
    }
  }

  void _resetCounter() {
    _counter = 0;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _handleTap, child: widget.child);
  }
}
