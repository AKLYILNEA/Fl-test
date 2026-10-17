import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/manager/font_manager.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

sealed class _FontChoice {
  const _FontChoice();
}

final class _DefaultFont extends _FontChoice {
  const _DefaultFont();
}

final class _CustomFont extends _FontChoice {
  const _CustomFont({required this.displayName, required this.fontFamily});

  final String displayName;
  final String fontFamily;

  @override
  bool operator ==(Object other) =>
      other is _CustomFont && other.displayName == displayName;

  @override
  int get hashCode => displayName.hashCode;
}

class FontFamilyView extends ConsumerStatefulWidget {
  const FontFamilyView({super.key});

  @override
  ConsumerState<FontFamilyView> createState() => _FontFamilyViewState();
}

class _FontFamilyViewState extends ConsumerState<FontFamilyView> {
  Future<void> _handlePickFont() async {
    final picked = await FontManager.pickAndApplyFont(context);
    if (picked && mounted) {
      ref
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(fontFamily: FontManager.customFontFamily));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final customFontName = FontManager.customFontName;
    final customFontFamily = FontManager.customFontFamily;

    final customItems = <_CustomFont>[
      if (customFontName != null &&
          customFontName.isNotEmpty &&
          customFontFamily != null &&
          customFontFamily.isNotEmpty)
        _CustomFont(
          displayName: customFontName,
          fontFamily: customFontFamily,
        ),
    ];

    return SelectionSheet<_FontChoice>(
      title: appLocalizations.fontFamily,
      iconActions: [
        IconButtonData(
          glyph: AppGlyphs.add,
          tooltip: appLocalizations.add,
          onPressed: _handlePickFont,
        ),
      ],
      sections: [
        const SelectionSection(items: [_DefaultFont()]),
        if (customItems.isNotEmpty)
          SelectionSection(
            label: appLocalizations.customFont,
            items: customItems,
          ),
      ],
      labelBuilder: (choice) => switch (choice) {
        _DefaultFont() => appLocalizations.defaultText,
        _CustomFont(:final displayName) => displayName,
      },
      titleBuilder: (choice, title) => switch (choice) {
        _DefaultFont() => title,
        _CustomFont(:final fontFamily) => Text(
          choice.displayName,
          style: TextStyle(fontFamily: fontFamily),
        ),
      },
      selectedOf: (ref) {
        final currentFont = FontManager.customFontFamily;
        if (currentFont != null &&
            currentFont.isNotEmpty &&
            customItems.isNotEmpty) {
          return customItems.first;
        }
        return const _DefaultFont();
      },
      onSelected: (choice) {
        switch (choice) {
          case _DefaultFont():
            FontManager.disableFont();
            ref
                .read(themeSettingProvider.notifier)
                .update((state) => state.copyWith(fontFamily: null));
          case _CustomFont(:final fontFamily):
            FontManager.fontFamilyNotifier.value = fontFamily;
            ref
                .read(themeSettingProvider.notifier)
                .update((state) => state.copyWith(fontFamily: fontFamily));
        }
      },
    );
  }
}
