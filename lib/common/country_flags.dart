import 'dart:ui';

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
  'ad', 'ae', 'af', 'ag', 'al', 'ao', 'at', 'be', 'bg', 'bh', 'bi', 'bm',
  'by', 'ca', 'cg', 'ch', 'cl', 'cm', 'cn', 'cq', 'dk', 'es', 'et', 'gb',
  'gl', 'gw', 'hk', 'id', 'im', 'ir', 'it', 'kg', 'kn', 'kw', 'lb', 'li',
  'lr', 'lt', 'lv', 'ly', 'ma', 'mc', 'md', 'me', 'mk', 'ml', 'mm', 'mn',
  'mr', 'mt', 'mv', 'mx', 'my', 'np', 'om', 'pe', 'pf', 'pg', 'pl', 'pr',
  'pt', 'qa', 'ro', 'sd', 'sg', 'sn', 'su', 'td', 'tj', 'tl', 'tn', 'to',
  'tr', 'tt', 'tw', 'ug', 'uk', 'um', 'us', 'vn', 'wf', 'ws',
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
  'bd', 'bf', 'bj', 'bo', 'br', 'cc', 'ci', 'dj', 'dm', 'dz', 'eh', 'gd',
  'gh', 'gm', 'gn', 'gy', 'hu', 'in', 'jm', 'jo', 'ke', 'mg', 'mo', 'mq',
  'mu', 'mw', 'na', 'nc', 'ne', 'nf', 'ng', 'pk', 'ps', 'sa', 'sb', 'sc',
  'sr', 'ss', 'st', 'tg', 'tm', 'uz', 'vu', 'zm', 'zw',
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
/// [CountryFlagTone.grey], and blue/white/red flags where white + blue exceed
/// red (such as FR, RU) resolve to [CountryFlagTone.blue].
CountryFlagTone countryFlagTone(String? countryCode) {
  if (countryCode == null) return CountryFlagTone.grey;
  final code = countryCode.trim().toLowerCase();
  if (_redFlags.contains(code)) return CountryFlagTone.red;
  if (_blueFlags.contains(code)) return CountryFlagTone.blue;
  if (_yellowFlags.contains(code)) return CountryFlagTone.yellow;
  if (_greenFlags.contains(code)) return CountryFlagTone.green;
  return CountryFlagTone.grey;
}

/// Returns the outer ring and soft ambient glow colors for [tone].
({Color ring, Color glow}) countryFlagRingColors(
  CountryFlagTone tone,
  Brightness brightness,
) {
  final isDark = brightness == Brightness.dark;
  return switch (tone) {
    CountryFlagTone.grey => isDark
        ? (ring: const Color(0x7094A3B8), glow: const Color(0x3D94A3B8))
        : (ring: const Color(0x5764748B), glow: const Color(0x2E64748B)),
    CountryFlagTone.red => isDark
        ? (ring: const Color(0x85FF5C5C), glow: const Color(0x5CFF5C5C))
        : (ring: const Color(0x61E03131), glow: const Color(0x3DE03131)),
    CountryFlagTone.blue => isDark
        ? (ring: const Color(0x854DA3FF), glow: const Color(0x5C4DA3FF))
        : (ring: const Color(0x611971C2), glow: const Color(0x3D1971C2)),
    CountryFlagTone.yellow => isDark
        ? (ring: const Color(0x85FFC13B), glow: const Color(0x57FFC13B))
        : (ring: const Color(0x6BE69A00), glow: const Color(0x40E69A00)),
    CountryFlagTone.green => isDark
        ? (ring: const Color(0x854CD97B), glow: const Color(0x574CD97B))
        : (ring: const Color(0x612B9348), glow: const Color(0x3D2B9348)),
  };
}
