const iperfDefaultPort = 5201;
const iperfMaxStreams = 128;
const iperfMaxDuration = 3600;
const iperfMaxBandwidth = 100000;

typedef IperfTarget = ({String name, List<String> hosts, int port});

String buildIperfLink({
  required List<String> hosts,
  required int port,
  required String name,
}) => Uri(
  scheme: 'flclash',
  host: 'iperf',
  queryParameters: {
    'addr': hosts.join(','),
    'port': '$port',
    if (name.isNotEmpty) 'name': name,
  },
).toString();

IperfTarget? parseIperfLink(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null ||
      !['bettbox', 'flclash'].contains(uri.scheme) ||
      uri.host != 'iperf') {
    return null;
  }
  final hosts = (uri.queryParameters['addr'] ?? '')
      .split(',')
      .map((host) => host.trim())
      .where((host) => host.isNotEmpty)
      .toList();
  final port = int.tryParse(uri.queryParameters['port'] ?? '') ?? 0;
  if (hosts.isEmpty || port < 1 || port > 65535) return null;
  return (name: uri.queryParameters['name'] ?? '', hosts: hosts, port: port);
}

({String host, int port})? parseIperfAddress(String value) {
  final text = value.trim();
  if (text.isEmpty || text.contains(RegExp(r'[\s/]'))) return null;
  int? parsePort(String raw) {
    final port = int.tryParse(raw);
    return port != null && port > 0 && port <= 65535 ? port : null;
  }

  if (text.startsWith('[')) {
    final end = text.indexOf(']');
    if (end <= 1) return null;
    final host = text.substring(1, end);
    final rest = text.substring(end + 1);
    if (rest.isEmpty) return (host: host, port: iperfDefaultPort);
    if (!rest.startsWith(':')) return null;
    final port = parsePort(rest.substring(1));
    return port == null ? null : (host: host, port: port);
  }
  if (':'.allMatches(text).length == 1) {
    final index = text.indexOf(':');
    final port = parsePort(text.substring(index + 1));
    if (port == null || index == 0) return null;
    return (host: text.substring(0, index), port: port);
  }
  return (host: text, port: iperfDefaultPort);
}

String formatIperfAddress(String host, int port) {
  if (port == iperfDefaultPort) return host;
  return host.contains(':') ? '[$host]:$port' : '$host:$port';
}
