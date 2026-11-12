import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

import 'risk_model.dart';

const riskGradient = [Color(0xFF4CAF50), Color(0xFFC57F0A), Color(0xFFEF5350)];

Color riskScoreColor(int score) {
  final t = score.clamp(0, 100) / 100;
  return t < .5
      ? Color.lerp(riskGradient[0], riskGradient[1], t * 2)!
      : Color.lerp(riskGradient[1], riskGradient[2], (t - .5) * 2)!;
}

extension RiskView on IpRisk {
  String? typeLabel(BuildContext context) => isDatacenter
      ? context.appLocalizations.ipRiskDatacenter
      : isResidentialProxy
      ? context.appLocalizations.ipRiskResidentialProxy
      : null;
  String levelLabel(BuildContext context) => switch (level) {
    IpRiskLevel.low => context.appLocalizations.ipRiskLow,
    IpRiskLevel.medium => context.appLocalizations.ipRiskMedium,
    IpRiskLevel.high => context.appLocalizations.ipRiskHigh,
    IpRiskLevel.veryHigh => context.appLocalizations.ipRiskVeryHigh,
  };
}

String riskCheckLabel(BuildContext context, String name) {
  final l = context.appLocalizations;
  return switch (name) {
    'Datacenter' => l.ipRiskDatacenter,
    'Residential Proxy' => l.ipRiskResidentialProxy,
    'Anonymizing VPN' => l.ipRiskAnonymousVpn,
    'Tor Exit Node' => l.ipRiskTorExit,
    'Server' => l.ipRiskServer,
    'Public Proxy' => l.ipRiskPublicProxy,
    'Web Proxy' => l.ipRiskWebProxy,
    'Search Engine Robot' => l.ipRiskSearchRobot,
    _ => name,
  };
}

class RiskScoreCard extends StatelessWidget {
  const RiskScoreCard({super.key, required this.risk});
  final IpRisk risk;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    final color = riskScoreColor(risk.displayScore);
    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l.ipRiskScore, style: AppTextStyle.subheadline.of(context)),
              const SizedBox(width: 4),
              MinIconButtonTheme(
                child: IconButton(
                  tooltip: l.ipRiskNoteTitle,
                  onPressed: () => dialogs.showAlert(
                    message: TextSpan(text: l.ipRiskNoteGeneric),
                  ),
                  icon: const GlyphIcon(AppGlyphs.info, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${risk.displayScore}',
                    style: AppTextStyle.display
                        .of(context, emphasized: true)
                        .toTabular
                        .copyWith(color: color),
                  ),
                  Text(
                    ' / 100',
                    style: AppTextStyle.body
                        .of(context)
                        .copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: ShapeDecoration(
                  color: color.withValues(alpha: .12),
                  shape: AppShape.sm,
                ),
                child: Text(
                  risk.levelLabel(context),
                  style: AppTextStyle.footnote
                      .of(context, emphasized: true)
                      .copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: '${l.ipRiskScore} ${risk.displayScore} / 100',
            child: SizedBox(
              height: 24,
              width: double.infinity,
              child: CustomPaint(
                painter: _RiskScale(
                  risk.displayScore,
                  context.colorScheme.surface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.ipRiskLow, style: AppTextStyle.footnote.of(context)),
              Text(l.ipRiskHigh, style: AppTextStyle.footnote.of(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskScale extends CustomPainter {
  const _RiskScale(this.score, this.surface);
  final int score;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      8,
      8,
      (size.width - 16).clamp(0, double.infinity),
      8,
    );
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
        rect.left + rect.width * score.clamp(0, 100) / 100,
        size.height,
      ),
    );
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndRadius(rect, AppRadius.full.topLeft),
      Paint()
        ..shader = const LinearGradient(
          colors: riskGradient,
        ).createShader(rect),
    );
    canvas.restore();
    final center = Offset(
      rect.left + rect.width * score.clamp(0, 100) / 100,
      12,
    );
    canvas.drawCircle(center, 8, Paint()..color = riskScoreColor(score));
    canvas.drawCircle(center, 4, Paint()..color = surface);
  }

  @override
  bool shouldRepaint(_RiskScale oldDelegate) =>
      score != oldDelegate.score || surface != oldDelegate.surface;
}

class RiskChecksCard extends StatelessWidget {
  const RiskChecksCard({super.key, required this.risk});
  final IpRisk risk;

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return Card(
      radius: AppCorner.xl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final group in IpRiskGroup.values) ...[
            if (group != IpRiskGroup.datacenter) const SizedBox(height: 20),
            Text(
              switch (group) {
                IpRiskGroup.datacenter => l.ipRiskHostingOrProxy,
                IpRiskGroup.blacklist => l.ipRiskBlacklist,
                IpRiskGroup.proxy => l.ipRiskProxyType,
              },
              style: AppTextStyle.footnote
                  .of(context)
                  .copyWith(color: context.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final check in risk.checks.where((c) => c.group == group))
                  _RiskFlag(check: check),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RiskFlag extends StatelessWidget {
  const _RiskFlag({required this.check});
  final IpRiskCheck check;

  @override
  Widget build(BuildContext context) {
    final hit = check.hit == true;
    final color = hit
        ? context.colorScheme.error
        : context.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: ShapeDecoration(
        color: hit
            ? color.withValues(alpha: .1)
            : context.colorScheme.onSurface.withValues(alpha: .045),
        shape: AppShape.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hit)
            GlyphIcon(AppGlyphs.error, size: 14, color: color)
          else if (check.hit == null)
            Text(
              '—',
              style: AppTextStyle.caption1.of(context).copyWith(color: color),
            )
          else
            DecoratedBox(
              decoration: ShapeDecoration(
                shape: AppShape.circle.copyWith(
                  side: BorderSide(color: color, width: 1.4),
                ),
              ),
              child: const SizedBox.square(dimension: 12),
            ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              riskCheckLabel(context, check.name),
              style: AppTextStyle.footnote
                  .of(context, emphasized: hit)
                  .copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
