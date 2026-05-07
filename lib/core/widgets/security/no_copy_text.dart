import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Renders [text] as a [SelectableText] with copy action disabled.
/// Use for sensitive fields: patient phone numbers, license numbers, etc.
class NoCopyText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const NoCopyText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: style,
      contextMenuBuilder: (_, __) => const SizedBox.shrink(),
      onSelectionChanged: (selection, cause) {
        // Intercept copy — clear clipboard immediately.
        if (cause == SelectionChangedCause.longPress ||
            cause == SelectionChangedCause.toolbar) {
          Clipboard.setData(const ClipboardData(text: ''));
        }
      },
    );
  }
}
