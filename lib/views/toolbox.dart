import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/toolbox/age_page.dart';
import 'package:fl_clash/features/toolbox/catalog.dart';
import 'package:fl_clash/features/toolbox/diagnostics.dart';
import 'package:fl_clash/features/toolbox/ip_page.dart';
import 'package:fl_clash/features/toolbox/widgets.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

class ToolboxView extends StatelessWidget {
  const ToolboxView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return ToolPageFrame(
      title: l.toolbox,
      children: [
        ToolMessage(l.toolboxDesc),
        generateSection(
          items: [
            for (final tool in ToolboxTool.values)
              ListItem.open(
                leading: GlyphIcon(tool.glyph),
                title: Text(tool.title(l)),
                subtitle: Text(tool.description(l)),
                widget: switch (tool) {
                  ToolboxTool.age => const AgeToolPage(),
                  ToolboxTool.ip => const IpLookupPage(),
                  _ => DiagnosticToolPage(tool: tool),
                },
              ),
          ],
        ),
      ],
    );
  }
}
