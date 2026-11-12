import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client.dart';
import 'widgets.dart';

class AgeToolPage extends ConsumerStatefulWidget {
  const AgeToolPage({super.key, this.client});
  final ToolboxClient? client;

  @override
  ConsumerState<AgeToolPage> createState() => _AgeToolPageState();
}

class _AgeToolPageState extends ConsumerState<AgeToolPage> {
  final _input = TextEditingController();
  final _keys = TextEditingController();
  final _public = TextEditingController();
  final _secret = TextEditingController();
  int _tab = 0;
  bool _hybrid = false;
  bool _busy = false;
  bool _showSecret = false;
  String? _error;
  String? _output;

  ToolboxClient get _client => widget.client ?? toolboxClient;

  @override
  void dispose() {
    for (final controller in [_input, _keys, _public, _secret]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _run({bool derive = false}) async {
    if (_busy) return;
    final l = context.appLocalizations;
    if (_tab != 0 && (_input.text.isEmpty || _keys.text.trim().isEmpty)) {
      setState(
        () => _error = _input.text.isEmpty
            ? l.ageInputRequired
            : l.ageRecipientRequired,
      );
      return;
    }
    if (utf8.encode(_input.text).length > 8 * 1024 * 1024) {
      setState(() => _error = l.ageFileTooLarge);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _output = null;
    });
    try {
      if (_tab == 0) {
        final result = await _client.query(CoreMethod.toolboxAgeKeys, {
          'hybrid': _hybrid,
          if (derive) 'secret': _secret.text.trim(),
        });
        if (!mounted) return;
        setState(() {
          _secret.text = result['secret-key'] as String;
          _public.text = result['public-key'] as String;
        });
      } else {
        final result = await _client.query(CoreMethod.toolboxAgeCrypt, {
          'mode': _tab == 1 ? 'encrypt' : 'decrypt',
          'data': _input.text,
          'keys': _keys.text
              .split('\n')
              .map((key) => key.trim())
              .where((key) => key.isNotEmpty)
              .toList(),
        });
        if (!mounted) return;
        setState(() {
          final error = result['error'];
          _error = error == null || error == '' ? null : '$error';
          _output = _error == null ? result['data'] as String? : null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFile() async {
    try {
      final file = await picker.pickerFile();
      if (file == null) return;
      final bytes = await file.readBytes();
      if (bytes.length > 8 * 1024 * 1024) {
        throw StateError(currentAppLocalizations.ageFileTooLarge);
      }
      if (mounted) setState(() => _input.text = utf8.decode(bytes));
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<void> _saveFile() async {
    final output = _output;
    if (output == null) return;
    try {
      await picker.saveFile(
        _tab == 1 ? 'encrypted.age' : 'decrypted.txt',
        Uint8List.fromList(utf8.encode(output)),
      );
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.appLocalizations;
    return ToolPageFrame(
      title: l.ageTool,
      actions: [
        if (_tab != 0)
          IconButtonData(
            glyph: AppGlyphs.importFile,
            tooltip: l.tbImport,
            onPressed: _busy ? null : _pickFile,
          ),
        if (_output != null) ...[
          toolCopyAction(context, _output),
          IconButtonData(
            glyph: AppGlyphs.export,
            tooltip: l.tbExport,
            onPressed: _saveFile,
          ),
        ],
      ],
      children: [
        ToolMessage(l.ageToolTip),
        IgnorePointer(
          ignoring: _busy,
          child: SegmentedControl<int>(
            segments: [
              (0, l.ageTabKeys),
              (1, l.ageTabEncrypt),
              (2, l.ageTabDecrypt),
            ],
            value: _tab,
            onChanged: (v) => setState(() {
              _tab = v;
              _error = null;
              _output = null;
            }),
          ),
        ),
        const SizedBox(height: 20),
        if (_tab == 0) ...[
          generateSection(
            items: [
              ListItem<bool>.options(
                title: Text(l.ageKeyType),
                options: const [false, true],
                value: _hybrid,
                textBuilder: (v) => v ? 'MLKEM768-X25519' : 'X25519',
                onChanged: (v) => setState(() => _hybrid = v),
              ),
              ListItem.toggle(
                title: Text(l.agePrivateKeyLabel),
                value: _showSecret,
                onChanged: (v) => setState(() => _showSecret = v),
              ),
            ],
          ),
          if (_hybrid) ToolMessage(l.ageKeyHybridTip),
          ToolField(
            label: l.agePrivateKeyLabel,
            controller: _secret,
            secret: !_showSecret,
          ),
          ToolField(
            label: l.agePublicKeyLabel,
            controller: _public,
            multiline: true,
          ),
          ToolRunButton(busy: _busy, onRun: _run, label: l.ageGenerateKeyPair),
          TextButton(
            onPressed: _busy || _secret.text.isEmpty
                ? null
                : () => _run(derive: true),
            child: Text(l.agePublicKeyLabel),
          ),
          TextButton(
            onPressed: _public.text.isEmpty
                ? null
                : () => setState(() {
                    _tab = 1;
                    _keys.text = _public.text;
                  }),
            child: Text(l.ageUseForEncrypt),
          ),
          toolCopyButton(context, _public.text),
        ] else ...[
          ToolField(
            label: _tab == 1 ? l.ageRecipients : l.agePrivateKeyLabel,
            controller: _keys,
            multiline: true,
          ),
          if (_tab == 2)
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      final key =
                          ref.read(currentProfileProvider)?.ageSecretKey ?? '';
                      setState(() => _keys.text = key);
                    },
              child: Text(l.ageUseProfileKey),
            ),
          ToolField(
            label: _tab == 1 ? l.agePlainText : l.ageCipherText,
            controller: _input,
            multiline: true,
          ),
          ToolRunButton(
            busy: _busy,
            onRun: _run,
            label: _tab == 1 ? l.ageTabEncrypt : l.ageTabDecrypt,
          ),
        ],
        if (_error != null) ToolMessage(_error!, error: true),
        if (_output != null) ...[
          ListHeader(title: l.ageOutput),
          Card(
            radius: AppCorner.xl,
            padding: const EdgeInsets.all(16),
            child: SelectableText(_output!),
          ),
        ],
      ],
    );
  }
}

Widget toolCopyButton(BuildContext context, String text) => TextButton(
  onPressed: text.isEmpty ? null : toolCopyAction(context, text).onPressed,
  child: Text(context.appLocalizations.copy),
);
