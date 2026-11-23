import 'dart:ui';

import 'package:flutter/foundation.dart' show clampDouble;
import 'package:prism_ui/color.dart' show ColorStyle;
import 'package:prism_ui/hct/hct.dart';
import 'package:prism_ui/theme_data.dart' show ColorScheme;

/// The five curated halo ring tones for circular country flags.
enum CountryFlagTone { grey, red, blue, yellow, green }

const _availableCountryFlags = <String>{
  'ac', 'ad', 'ae', 'af', 'ag', 'ai', 'al', 'am', 'an', 'ao', 'aq', 'ar',
  'as', 'at', 'au', 'aw', 'ax', 'az', 'ba', 'bb', 'bd', 'be', 'bf', 'bg',
  'bh', 'bi', 'bj', 'bl', 'bm', 'bn', 'bo', 'bq', 'br', 'bs', 'bt', 'bv',
  'bw', 'by', 'bz', 'ca', 'cc', 'cd', 'cf', 'cg', 'ch', 'ci', 'ck', 'cl',
  'cm', 'cn', 'co', 'cp', 'cq', 'cr', 'cu', 'cv', 'cw', 'cx', 'cy', 'cz',
  'de', 'dg', 'dj', 'dk', 'dm', 'do', 'dz', 'ea', 'ec', 'ee', 'eg', 'eh',
  'er', 'es', 'et', 'eu', 'fi', 'fj', 'fk', 'fm', 'fo', 'fr', 'fx', 'ga',
  'gb', 'gd', 'ge', 'gf', 'gg', 'gh', 'gi', 'gl', 'gm', 'gn', 'gp', 'gq',
  'gr', 'gs', 'gt', 'gu', 'gw', 'gy', 'hk', 'hm', 'hn', 'hr', 'ht', 'hu',
  'ic', 'id', 'ie', 'il', 'im', 'in', 'io', 'iq', 'ir', 'is', 'it', 'je',
  'jm', 'jo', 'jp', 'ke', 'kg', 'kh', 'ki', 'km', 'kn', 'kp', 'kr', 'kw',
  'ky', 'kz', 'la', 'lb', 'lc', 'li', 'lk', 'lr', 'ls', 'lt', 'lu', 'lv',
  'ly', 'ma', 'mc', 'md', 'me', 'mf', 'mg', 'mh', 'mk', 'ml', 'mm', 'mn',
  'mo', 'mp', 'mq', 'mr', 'ms', 'mt', 'mu', 'mv', 'mw', 'mx', 'my', 'mz',
  'na', 'nc', 'ne', 'nf', 'ng', 'ni', 'nl', 'no', 'np', 'nr', 'nu', 'nz',
  'om', 'pa', 'pe', 'pf', 'pg', 'ph', 'pk', 'pl', 'pm', 'pn', 'pr', 'ps',
  'pt', 'pw', 'py', 'qa', 're', 'ro', 'rs', 'ru', 'rw', 'sa', 'sb', 'sc',
  'sd', 'se', 'sg', 'sh', 'si', 'sj', 'sk', 'sl', 'sm', 'sn', 'so', 'sr',
  'ss', 'st', 'su', 'sv', 'sx', 'sy', 'sz', 'ta', 'tc', 'td', 'tf', 'tg',
  'th', 'tj', 'tk', 'tl', 'tm', 'tn', 'to', 'tr', 'tt', 'tv', 'tw', 'tz',
  'ua', 'ug', 'uk', 'um', 'un', 'us', 'uy', 'uz', 'va', 'vc', 've', 'vg',
  'vi', 'vn', 'vu', 'wf', 'ws', 'xk', 'xx', 'ye', 'yt', 'yu', 'za', 'zm',
  'zw',
};

const _redFlags = <String>{
  'ad', 'af', 'ag', 'al', 'ao', 'at', 'be', 'bh', 'bm', 'by', 'ca', 'ch',
  'cl', 'cn', 'cq', 'dk', 'es', 'gb', 'gl', 'hk', 'id', 'im', 'kg', 'lb',
  'li', 'lr', 'lv', 'ma', 'mc', 'md', 'me', 'mk', 'mn', 'mt', 'mv', 'my',
  'np', 'om', 'pe', 'pf', 'pg', 'pl', 'pr', 'pt', 'qa', 'ro', 'sg', 'su',
  'td', 'tl', 'tn', 'to', 'tr', 'tt', 'tw', 'ug', 'uk', 'um', 'us', 'vn',
  'wf', 'ws',
};

const _blueFlags = <String>{
  'ac', 'ai', 'an', 'aq', 'ar', 'as', 'au', 'aw', 'ax', 'az', 'ba', 'bb',
  'bq', 'bs', 'bv', 'bw', 'bz', 'cd', 'ck', 'cp', 'cr', 'cu', 'cv', 'cw',
  'cx', 'cz', 'dg', 'do', 'er', 'eu', 'fj', 'fk', 'fm', 'fo', 'fr', 'fx',
  'ga', 'gp', 'gq', 'gr', 'gs', 'gt', 'gu', 'hm', 'hn', 'hr', 'ht', 'io',
  'is', 'kh', 'ki', 'km', 'kp', 'ky', 'kz', 'la', 'lc', 'ls', 'lu', 'mf',
  'mh', 'mp', 'ms', 'ni', 'nl', 'no', 'nr', 'nz', 'pa', 'ph', 'pm', 'pn',
  'pw', 'py', 're', 'rs', 'ru', 'rw', 'se', 'sh', 'si', 'sj', 'sk', 'sl',
  'sm', 'so', 'sv', 'sx', 'sz', 'ta', 'tc', 'tf', 'th', 'tk', 'tv', 'tz',
  'un', 've', 'vg', 'xk', 'yu', 'za',
};

const _yellowFlags = <String>{
  'am', 'bn', 'bt', 'cf', 'co', 'de', 'ec', 'gf', 'ic', 'ie', 'lk', 'mz',
  'nu', 'ua', 'va', 'vc',
};

const _greenFlags = <String>{
  'ae', 'bd', 'bf', 'bg', 'bi', 'bj', 'bo', 'br', 'cc', 'cg', 'ci', 'cm',
  'dj', 'dm', 'dz', 'eh', 'et', 'gd', 'gh', 'gm', 'gn', 'gw', 'gy', 'hu',
  'in', 'ir', 'it', 'jm', 'jo', 'ke', 'kn', 'kw', 'lt', 'ly', 'mg', 'ml',
  'mm', 'mo', 'mq', 'mr', 'mu', 'mw', 'mx', 'na', 'nc', 'ne', 'nf', 'ng',
  'pk', 'ps', 'sa', 'sb', 'sc', 'sd', 'sn', 'sr', 'ss', 'st', 'tg', 'tj',
  'tm', 'uz', 'vu', 'zm', 'zw',
};

/// Returns the bundled circular SVG asset path for an ISO 3166-1 alpha-2 code.
String? countryFlagAsset(String? countryCode) {
  if (countryCode == null) return null;
  final code = countryCode.trim().toLowerCase();
  if (!_availableCountryFlags.contains(code)) return null;
  return 'assets/images/flags/$code.svg';
}

/// Returns the curated 5-tone border category for [countryCode].
///
/// White-rim or neutral flags (such as JP, KR, FI) resolve to
/// [CountryFlagTone.grey]; blue/white/red flags where white + blue exceed red
/// (such as FR, RU) resolve to [CountryFlagTone.blue]; green-heavy flags
/// (such as IT, MX, MR, BG, IR) resolve to [CountryFlagTone.green].
CountryFlagTone countryFlagTone(String? countryCode) {
  if (countryCode == null) return CountryFlagTone.grey;
  final code = countryCode.trim().toLowerCase();
  if (_redFlags.contains(code)) return CountryFlagTone.red;
  if (_blueFlags.contains(code)) return CountryFlagTone.blue;
  if (_yellowFlags.contains(code)) return CountryFlagTone.yellow;
  if (_greenFlags.contains(code)) return CountryFlagTone.green;
  return CountryFlagTone.grey;
}

double _maxHctChroma(double hue, double tone) =>
    Hct.from(hue, 150.0, tone).chroma;

/// Derives the circular flag outer ring and two-layer feathered ambient bloom
/// colors in HCT space from the active theme's perceptual tone and relative
/// chroma ratio, so any theme colors sharing the same `(tone, chromaRatio)`
/// (e.g. `#ADCAFF`, `#C4C4FF`, `#DEBBFF`, `#E6C900`, `#00E93D`) produce the
/// exact same 5-color ring palette (`red`, `blue`, `yellow`, `green`, `grey`).
({Color ring, Color glow, Color innerGlow}) countryFlagRingColors(
  CountryFlagTone tone,
  ColorScheme colorScheme,
  ColorStyle style, {
  Color? seedColor,
}) {
  final isDark = colorScheme.brightness == Brightness.dark;
  final source = Hct.fromInt((seedColor ?? colorScheme.primary).toARGB32());
  final maxSourceChroma = _maxHctChroma(source.hue, source.tone);
  final chromaRatio = maxSourceChroma > 1.0
      ? clampDouble(source.chroma / maxSourceChroma, 0.0, 1.0)
      : 0.0;

  if (style == ColorStyle.monochrome || source.chroma < 8.0) {
    final base = Color(Hct.from(0.0, 0.0, isDark ? 68.0 : 54.0).toInt());
    final glowAlpha = isDark ? 0.14 : 0.09;
    return (
      ring: base.withValues(alpha: isDark ? 0.44 : 0.34),
      glow: base.withValues(alpha: glowAlpha),
      innerGlow: base.withValues(alpha: glowAlpha * 0.55),
    );
  }

  final targetTone = switch (style) {
    ColorStyle.vivid => isDark
        ? clampDouble(source.tone + 3.0, 46.0, 84.0)
        : clampDouble(source.tone, 34.0, 82.0),
    ColorStyle.tinted => isDark
        ? clampDouble(source.tone + 3.0, 48.0, 84.0)
        : clampDouble(source.tone, 36.0, 82.0),
    ColorStyle.soft => isDark
        ? clampDouble(source.tone * 0.45 + 78.0 * 0.55, 68.0, 82.0)
        : clampDouble(source.tone * 0.45 + 58.0 * 0.55, 52.0, 74.0),
    ColorStyle.monochrome => isDark ? 68.0 : 54.0,
  };

  final lightBoost = isDark
      ? 0.0
      : clampDouble((targetTone - 58.0) / 26.0, 0.0, 1.0) * 0.30;

  if (tone == CountryFlagTone.grey) {
    final greyTone = isDark
        ? clampDouble(targetTone, 56.0, 80.0)
        : clampDouble(targetTone, 46.0, 76.0);
    final base = Color(Hct.from(0.0, 0.0, greyTone).toInt());
    final glowAlpha = isDark ? 0.15 : 0.09;
    return (
      ring: base.withValues(
        alpha: clampDouble((isDark ? 0.44 : 0.36) + lightBoost * 0.7, 0.34, 0.72),
      ),
      glow: base.withValues(alpha: glowAlpha),
      innerGlow: base.withValues(alpha: glowAlpha * 0.55),
    );
  }

  final canonicalHue = switch (tone) {
    CountryFlagTone.red => 20.0,
    CountryFlagTone.blue => 252.0,
    CountryFlagTone.green => 145.0,
    CountryFlagTone.yellow => 96.0,
    CountryFlagTone.grey => 0.0,
  };

  final maxTargetChroma = _maxHctChroma(canonicalHue, targetTone);
  final chroma = switch (style) {
    ColorStyle.vivid => maxTargetChroma * chromaRatio,
    ColorStyle.tinted => clampDouble(
      maxTargetChroma * chromaRatio * 0.80,
      0.0,
      72.0,
    ),
    ColorStyle.soft => clampDouble(
      maxTargetChroma * chromaRatio * 0.52,
      0.0,
      36.0,
    ),
    ColorStyle.monochrome => 0.0,
  };

  final (baseRingAlpha, glowAlpha) = switch (style) {
    ColorStyle.vivid => (isDark ? 0.54 : 0.48, isDark ? 0.22 : 0.14),
    ColorStyle.tinted => (isDark ? 0.50 : 0.44, isDark ? 0.21 : 0.14),
    ColorStyle.soft => (isDark ? 0.46 : 0.42, isDark ? 0.18 : 0.12),
    ColorStyle.monochrome => (isDark ? 0.44 : 0.34, isDark ? 0.14 : 0.09),
  };

  final base = Color(Hct.from(canonicalHue, chroma, targetTone).toInt());
  return (
    ring: base.withValues(
      alpha: clampDouble(baseRingAlpha + lightBoost, 0.34, 0.80),
    ),
    glow: base.withValues(alpha: glowAlpha),
    innerGlow: base.withValues(alpha: glowAlpha * 0.55),
  );
}

List<double> _flagToneMatrix(
  double saturation,
  double contrast,
  double brightness,
) {
  final scale = brightness * contrast;
  final offset = brightness * 127.5 * (1.0 - contrast);
  final inv = 1.0 - saturation;
  final r = 0.2126 * inv;
  final g = 0.7152 * inv;
  final b = 0.0722 * inv;
  return [
    scale * (r + saturation),
    scale * g,
    scale * b,
    0,
    offset,
    scale * r,
    scale * (g + saturation),
    scale * b,
    0,
    offset,
    scale * r,
    scale * g,
    scale * (b + saturation),
    0,
    offset,
    0,
    0,
    0,
    1,
    0,
  ];
}

/// Derives the adaptive recoloring matrix, subtle theme tint veil, paper veil,
/// and inner rim hairline applied over the circular flag SVG.
({List<double> colorMatrix, Color tintVeil, Color paperVeil, Color innerRim})
countryFlagOverlayStyle(ColorScheme colorScheme, ColorStyle style) {
  final isDark = colorScheme.brightness == Brightness.dark;
  final primary = Hct.fromInt(colorScheme.primary.toARGB32());
  final isAchromatic = style == ColorStyle.monochrome || primary.chroma < 8.0;

  final (saturation, contrast, brightness) = isAchromatic
      ? (0.04, isDark ? 0.95 : 0.94, isDark ? 0.86 : 1.0)
      : switch (style) {
          ColorStyle.soft => (
            isDark ? 0.74 : 0.78,
            isDark ? 0.94 : 0.95,
            isDark ? 0.86 : 1.0,
          ),
          ColorStyle.tinted => (
            isDark ? 0.82 : 0.86,
            0.96,
            isDark ? 0.87 : 1.0,
          ),
          ColorStyle.vivid || ColorStyle.monochrome => (
            isDark ? 0.88 : 0.91,
            0.97,
            isDark ? 0.88 : 1.0,
          ),
        };

  final tintAlpha = isAchromatic
      ? 0.0
      : switch (style) {
          ColorStyle.tinted => isDark ? 0.13 : 0.10,
          ColorStyle.soft => isDark ? 0.07 : 0.05,
          ColorStyle.vivid || ColorStyle.monochrome => isDark ? 0.06 : 0.045,
        };

  return (
    colorMatrix: _flagToneMatrix(saturation, contrast, brightness),
    tintVeil: tintAlpha > 0
        ? colorScheme.primary.withValues(alpha: tintAlpha)
        : const Color(0x00000000),
    paperVeil: isDark ? const Color(0x17121418) : const Color(0x0FFFFFFF),
    innerRim: isDark ? const Color(0x1FFFFFFF) : const Color(0x14000000),
  );
}
