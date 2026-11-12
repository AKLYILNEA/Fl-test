import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/ui/icons/icons.dart';

enum ToolboxTool {
  speed,
  route,
  ip,
  mrs,
  dns,
  nat,
  ping,
  iperf,
  age,
  traffic;

  String title(AppLocalizations l) => switch (this) {
    speed => l.speedTest,
    route => l.routeTrace,
    ip => l.ipLookup,
    mrs => l.mrsLookup,
    dns => l.dnsQuery,
    nat => l.natTest,
    ping => l.localPing,
    iperf => l.iperfTest,
    age => l.ageTool,
    traffic => l.trafficUsage,
  };

  String description(AppLocalizations l) => switch (this) {
    speed => l.toolSpeedTestDesc,
    route => l.routeTraceDesc,
    ip => l.ipLookupDesc,
    mrs => l.mrsLookupDesc,
    dns => l.dnsQueryDesc,
    nat => l.natTestDesc,
    ping => l.localPingDesc,
    iperf => l.iperfTestDesc,
    age => l.ageToolDesc,
    traffic => l.trafficStatsDesc,
  };

  Glyph get glyph => switch (this) {
    speed => AppGlyphs.speed,
    route => AppGlyphs.connections,
    ip => AppGlyphs.proxies,
    mrs => AppGlyphs.resources,
    dns => AppGlyphs.dns,
    nat => AppGlyphs.target,
    ping => AppGlyphs.bolt,
    iperf => AppGlyphs.connections,
    age => AppGlyphs.key,
    traffic => AppGlyphs.dashboard,
  };
}
