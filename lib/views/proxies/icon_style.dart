import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/null_status_illustration.dart';
import 'package:fl_clash/views/profiles/custom/icon.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProxiesIconStyleView extends ConsumerStatefulWidget {
  const ProxiesIconStyleView({super.key});

  @override
  ConsumerState<ProxiesIconStyleView> createState() =>
      _ProxiesIconStyleViewState();
}

class _ProxiesIconStyleViewState extends ConsumerState<ProxiesIconStyleView> {
  void _handleStyle(ProxiesIconStyle iconStyle) {
    ref
        .read(proxiesStyleSettingProvider.notifier)
        .update((state) => state.copyWith(iconStyle: iconStyle));
  }

  void _putRules(List<IconRule> rules) {
    ref.read(iconRulesProvider.notifier).update(rules);
  }

  Future<void> _handleAdd() async {
    final rule = await showFormSheet<IconRule>(
      context: context,
      props: nestedPagedSheetProps,
      builder: (_) => NestedPagedSheet(
        builder: (_) => const _IconRuleForm(),
      ),
    );
    if (rule == null || !mounted) {
      return;
    }
    _putRules([...ref.read(iconRulesProvider), rule]);
  }

  Future<void> _handleEdit(int index) async {
    final rules = ref.read(iconRulesProvider);
    if (index >= rules.length) {
      return;
    }
    final rule = await showFormSheet<IconRule>(
      context: context,
      props: nestedPagedSheetProps,
      builder: (_) => NestedPagedSheet(
        builder: (_) => _IconRuleForm(
          rule: rules[index],
          onDelete: () => _handleDelete(index),
        ),
      ),
    );
    if (rule == null || !mounted) {
      return;
    }
    final next = [...ref.read(iconRulesProvider)];
    if (index < next.length) {
      next[index] = rule;
      _putRules(next);
    }
  }

  Future<bool> _handleDelete(int index) async {
    final appLocalizations = context.appLocalizations;
    final rules = ref.read(iconRulesProvider);
    if (index >= rules.length) {
      return false;
    }
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.deleteTip(rules[index].pattern)),
      destructive: true,
      confirmText: appLocalizations.delete,
    );
    if (res != true || !mounted) {
      return false;
    }
    final next = [...ref.read(iconRulesProvider)];
    if (index < next.length) {
      next.removeAt(index);
      _putRules(next);
    }
    return true;
  }

  Widget _buildRule(int index, IconRule rule) {
    final appLocalizations = context.appLocalizations;
    return ContextMenuRegion(
      menuItems: [
        PopupMenuItem(
          glyph: AppGlyphs.edit,
          label: appLocalizations.edit,
          onPressed: () => _handleEdit(index),
        ),
        PopupMenuItem(
          danger: true,
          glyph: AppGlyphs.delete,
          label: appLocalizations.delete,
          onPressed: () => _handleDelete(index),
        ),
      ],
      child: DecorationListItem(
        invalid: rule.regExp == null,
        leading: SizedBox.square(
          dimension: 32,
          child: IconTheme.merge(
            data: const IconThemeData(size: 32),
            child: CommonTargetIcon(src: rule.icon),
          ),
        ),
        title: TooltipText(
          text: Text(
            rule.pattern,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: rule.regExp == null
            ? Text(
                appLocalizations.invalidRegex,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.listCaptionStyle,
              )
            : null,
        trailing: const DisclosureIndicator(),
        onPressed: () => _handleEdit(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final iconStyle = ref.watch(
      proxiesStyleSettingProvider.select((state) => state.iconStyle),
    );
    final rules = ref.watch(iconRulesProvider);
    return Scaffold(
      title: appLocalizations.iconStyle,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: context.contentTopPadding + 8),
            sliver: SliverToBoxAdapter(
              child: SegmentedControl<ProxiesIconStyle>(
                segments: [
                  (ProxiesIconStyle.filled, appLocalizations.iconStyleFilled),
                  (ProxiesIconStyle.plain, appLocalizations.iconStylePlain),
                  (ProxiesIconStyle.hidden, appLocalizations.iconStyleHidden),
                ],
                value: iconStyle,
                onChanged: _handleStyle,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: ListHeader(
                title: appLocalizations.iconRules,
                actions: [
                  IconButtonData(
                    glyph: AppGlyphs.addCircle,
                    tooltip: appLocalizations.addIconRule,
                    onPressed: _handleAdd,
                  ),
                ],
              ),
            ),
          ),
          if (rules.isEmpty)
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 12),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 48),
                  child: NullStatus(
                    label: appLocalizations.iconRulesEmpty,
                    illustration: NullStatusIllustration.icons,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: generateGroup([
                  for (final (index, rule) in rules.indexed)
                    KeyedSubtree(
                      key: ValueKey('${rule.pattern}#${rule.icon}#$index'),
                      child: _buildRule(index, rule),
                    ),
                ]),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(bottom: 16 + context.bottomInset),
            sliver: SliverToBoxAdapter(
              child: ListFooter(
                text: appLocalizations.iconRulesTip,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconRuleForm extends ConsumerStatefulWidget {
  const _IconRuleForm({this.rule, this.onDelete});

  final IconRule? rule;
  final Future<bool> Function()? onDelete;

  @override
  ConsumerState<_IconRuleForm> createState() => _IconRuleFormState();
}

enum _RuleField { pattern, icon }

class _IconRuleFormState extends ConsumerState<_IconRuleForm> {
  late final TextEditingController _controller;
  String _icon = '';
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.rule?.pattern);
    _icon = widget.rule?.icon ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ({_RuleField field, String message})? _issue() {
    final appLocalizations = context.appLocalizations;
    final pattern = _controller.text.trim();
    if (pattern.isEmpty) {
      return (
        field: _RuleField.pattern,
        message: appLocalizations.emptyTip(appLocalizations.regex),
      );
    }
    try {
      RegExp(pattern);
    } catch (_) {
      return (
        field: _RuleField.pattern,
        message: appLocalizations.invalidRegex,
      );
    }
    if (_icon.isEmpty) {
      return (
        field: _RuleField.icon,
        message: appLocalizations.emptyTip(appLocalizations.icon),
      );
    }
    return null;
  }

  void _handleChanged(String _) {
    if (_attempted) {
      setState(() {});
    }
  }

  /// The same picker the custom groups use, with its link entry in the bar.
  Future<void> _handlePickIcon() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final value = await Navigator.of(context).push<String>(
      PagedSheetRoute(
        builder: (_) =>
            IconPickerView(value: _icon, groupName: _controller.text.trim()),
      ),
    );
    if (value == null || !mounted) {
      return;
    }
    setState(() {
      _icon = value;
    });
  }

  Future<void> _handleDelete() async {
    final deleted = await widget.onDelete?.call();
    if (deleted == true && mounted) {
      context.safeNestedPop();
    }
  }

  void _handleSubmit() {
    if (_issue() != null) {
      setState(() {
        _attempted = true;
      });
      return;
    }
    context.safeNestedPop(
      IconRule(pattern: _controller.text.trim(), icon: _icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final issue = _attempted ? _issue() : null;
    return Scaffold(
      title: widget.rule == null
          ? appLocalizations.addIconRule
          : appLocalizations.editIconRule,
      confirmationAction: IconButtonData(
        glyph: AppGlyphs.check,
        tooltip: appLocalizations.confirm,
        onPressed: _handleSubmit,
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: context.sectionsTopPadding,
          bottom: 20 + context.bottomInset,
        ),
        children: [
          ErrorBanner(message: issue?.message),
          generateSection(
            title: appLocalizations.general,
            items: [
              FormRow(
                title: appLocalizations.regex,
                invalid: issue?.field == _RuleField.pattern,
                trailing: FormRowTextField(
                  controller: _controller,
                  hintText: appLocalizations.required,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  onChanged: _handleChanged,
                  onFieldSubmitted: (_) => _handleSubmit(),
                ),
              ),
              FormRow(
                title: appLocalizations.icon,
                invalid: issue?.field == _RuleField.icon,
                onPressed: _handlePickIcon,
                trailing: Row(
                  spacing: 2,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_icon.isNotEmpty)
                      SizedBox.square(
                        dimension: 28,
                        child: IconTheme.merge(
                          data: const IconThemeData(size: 28),
                          child: CommonTargetIcon(src: _icon),
                        ),
                      )
                    else
                      Text(
                        appLocalizations.required,
                        style: context.listTitleStyle.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const GlyphIcon(AppGlyphs.chevronForward),
                  ],
                ),
              ),
            ],
          ),
          if (widget.rule != null)
            generateSection(
              title: appLocalizations.action,
              items: [
                FormRow(
                  title: appLocalizations.delete,
                  titleStyle: TextStyle(color: context.colorScheme.error),
                  onPressed: _handleDelete,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
