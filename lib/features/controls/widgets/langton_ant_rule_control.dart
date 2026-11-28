import 'package:flutter/material.dart';
import 'package:flutter_fractals/core/modules/fractals/langton_ant_frame.dart';
import 'package:flutter_fractals/l10n/app_localizations.dart';

class LangtonAntRuleControl extends StatefulWidget {
  const LangtonAntRuleControl(
      {super.key, required this.rule, required this.onApplied});

  final String rule;
  final ValueChanged<String> onApplied;

  @override
  State<LangtonAntRuleControl> createState() => _LangtonAntRuleControlState();
}

class _LangtonAntRuleControlState extends State<LangtonAntRuleControl> {
  late final _text = TextEditingController(text: widget.rule);
  bool _invalid = false;

  @override
  void didUpdateWidget(covariant LangtonAntRuleControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rule != widget.rule) {
      _text.text = widget.rule;
      _invalid = false;
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _apply() {
    final rule = normalizeLangtonAntRule(_text.text);
    setState(() => _invalid = rule == null);
    if (rule != null) {
      _text.value = TextEditingValue(
          text: rule, selection: TextSelection.collapsed(offset: rule.length));
      widget.onApplied(rule);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          key: const Key('langtonAntRule'),
          controller: _text,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: l10n.langtonAntRule,
            errorText: _invalid ? l10n.langtonAntInvalidRule : null,
            errorMaxLines: 2,
          ),
          onChanged: (_) {
            if (_invalid) setState(() => _invalid = false);
          },
          onSubmitted: (_) => _apply(),
        ),
        TextButton(onPressed: _apply, child: Text(l10n.actionApply)),
      ]),
    );
  }
}
