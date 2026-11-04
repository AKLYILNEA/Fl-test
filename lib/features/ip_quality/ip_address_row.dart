import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/ip.dart';
import 'package:fl_clash/features/ip_quality/ip_quality_sheet.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/ip_country.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/widgets/record.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IpAddressRow extends ConsumerWidget {
  const IpAddressRow({
    super.key,
    this.title,
    required this.address,
    this.countries = const [],
    this.allowDetails = true,
  });

  final String? title;
  final String address;
  final List<String> countries;
  final bool allowDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicIp = publicIpOf(address);
    final hidden =
        publicIp != null &&
        ref.watch(appSettingProvider.select((state) => state.hideIp));
    final port = hidden ? ipEndpointOf(address)?.port : null;
    final shown = hidden ? '*****${port == null ? '' : ':$port'}' : address;
    final maskedEndpoint = TextSpan(
      children: [
        TextSpan(text: '*****', style: const TextStyle().toJetBrainsMono),
        if (port != null) ...[
          // Masking removes the digit context that selects a raised numeric colon.
          const TextSpan(
            text: ':',
            style: TextStyle(fontFeatures: [FontFeature.caseSensitiveForms()]),
          ),
          TextSpan(text: port),
        ],
      ],
    );
    final ip = allowDetails ? publicIp : null;
    final title = this.title;
    if (ip == null) {
      return title == null
          ? DetailRow(title: shown, copyText: address)
          : DetailRow(
              title: title,
              copyText: address,
              value: hidden ? Text.rich(maskedEndpoint) : Text(shown),
            );
    }
    final country =
        countries
            .map((code) => code.toUpperCase())
            .where(
              (code) =>
                  RegExp(r'^[A-Z]{2}$').hasMatch(code) &&
                  code != 'ZZ' &&
                  code != 'XX',
            )
            .firstOrNull ??
        ref.watch(ipCountryProvider(ip)).value ??
        '';
    final prefix = country.isEmpty ? '' : '${country.countryFlagEmoji} ';
    final emojiFont = EmojiFont.of(context);
    final text = hidden
        ? Text.rich(
            TextSpan(
              children: [
                if (prefix.isNotEmpty)
                  EmojiText.spanOf(
                    prefix,
                    null,
                    emojiFamily: emojiFont?.family,
                    pattern: emojiFont?.pattern,
                  ),
                maskedEndpoint,
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : EmojiText(
            '$prefix$shown',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
    void openDetails() => showIpQualitySheet(context, ip: ip, outbound: false);
    if (title == null) {
      return DecorationListItem(title: text, onPressed: openDetails);
    }
    return DetailRow(title: title, onPressed: openDetails, value: text);
  }
}
