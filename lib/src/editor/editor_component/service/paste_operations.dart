import 'package:appflowy_editor/appflowy_editor.dart';

final _hrefRegex = RegExp(
  r'https?://(?:www\.)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(?:/[^\s]*)?',
);

final _phoneRegex = RegExp(r'^\+?(?:[0-9][\s-.]?)+[0-9]$');

String normalizePastedPlainText(String text) {
  // Normalize Windows and legacy Mac line endings before splitting paragraphs.
  return text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
}

String _normalizePastedParagraph(String paragraph) => paragraph.trimRight();

extension AppFlowyPasteOperations on EditorState {
  Future<bool> pasteHtmlContent(String html) async {
    final nodes = htmlToDocument(html).root.children.toList();

    while (nodes.isNotEmpty &&
        nodes.first.delta?.isEmpty == true &&
        nodes.first.children.isEmpty) {
      nodes.removeAt(0);
    }
    while (nodes.isNotEmpty &&
        nodes.last.delta?.isEmpty == true &&
        nodes.last.children.isEmpty) {
      nodes.removeLast();
    }

    if (nodes.isEmpty) {
      return false;
    }

    if (nodes.length == 1) {
      await pasteSingleLineNode(nodes.first);
    } else {
      await pasteMultiLineNodes(nodes);
    }

    return true;
  }

  Future<void> pastePlainTextContent(String plainText) async {
    final normalizedText = normalizePastedPlainText(plainText);
    final selectionAttributes = getDeltaAttributesInSelectionStart();
    final selection = await deleteSelectionIfNeeded();

    if (selection == null) {
      return;
    }

    if (await maybeConvertToUrlOrPhone(normalizedText)) {
      return;
    }

    final nodes = normalizedText
        .split('\n')
        .map(_normalizePastedParagraph)
        .map((paragraph) {
          final delta = Delta();
          final match =
              _hrefRegex.firstMatch(paragraph) ?? _phoneRegex.firstMatch(paragraph);

          if (match == null) {
            delta.insert(paragraph, attributes: selectionAttributes);
            return paragraphNode(delta: delta);
          }

          if (match.start > 0) {
            delta.insert(paragraph.substring(0, match.start));
          }

          final entity = match.group(0)!;
          delta.insert(
            paragraph.substring(match.start, match.end),
            attributes: {
              AppFlowyRichTextKeys.href:
                  _phoneRegex.hasMatch(entity) ? 'tel:$entity' : entity,
            },
          );

          if (match.end < paragraph.length) {
            delta.insert(paragraph.substring(match.end));
          }

          return paragraphNode(delta: delta);
        })
        .toList();

    if (nodes.isEmpty) {
      return;
    }

    if (nodes.length == 1) {
      await pasteSingleLineNode(nodes.first);
    } else {
      await pasteMultiLineNodes(nodes);
    }
  }

  Future<bool> maybeConvertToUrlOrPhone(String plainText) async {
    final selection = this.selection;
    if (selection == null ||
        !selection.isSingle ||
        selection.isCollapsed ||
        (!_hrefRegex.hasMatch(plainText) && !_phoneRegex.hasMatch(plainText))) {
      return false;
    }

    final node = getNodeAtPath(selection.start.path);
    if (node == null) {
      return false;
    }

    final isPhone = _phoneRegex.hasMatch(plainText);
    final transaction = this.transaction
      ..formatText(node, selection.startIndex, selection.length, {
        AppFlowyRichTextKeys.href: isPhone ? 'tel:$plainText' : plainText,
      });

    await apply(transaction);
    return true;
  }
}