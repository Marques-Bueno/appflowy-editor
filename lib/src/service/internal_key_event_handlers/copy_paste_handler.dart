import 'package:appflowy_editor/appflowy_editor.dart';

Future<void> handlePastePlainText(
  EditorState editorState,
  String plainText,
) {
  // Expose the async paste pipeline so callers can wait for document mutations.
  return editorState.pastePlainTextContent(plainText);
}

Future<bool> pasteHTML(EditorState editorState, String html) {
  // HTML paste mutates the document asynchronously as well.
  return editorState.pasteHtmlContent(html);
}


void handleCopy(EditorState editorState) async {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return;
  }
  String text;
  String html;

  if (selection.isCollapsed) {
    final node = editorState.getNodeAtPath(selection.end.path);
    if (node == null) {
      return;
    }
    text = node.delta?.toPlainText() ?? '';
    html = documentToHTML(
      Document(
        root: pageNode(children: [node.copyWith()]),
      ),
    );
  } else {
    text = editorState.getTextInSelection(selection).join('\n');
    final nodes = editorState.getSelectedNodes(selection: selection);
    if (nodes.isEmpty) {
      return;
    }
    html = documentToHTML(
      Document(
        root: pageNode(
          children: nodes.map((node) => node.copyWith()),
        ),
      ),
    );
  }

  return AppFlowyClipboard.setData(
    text: text,
    html: html.isEmpty ? null : html,
  );
}


Future<void> handlePaste(EditorState editorState) async {
  final data = await AppFlowyClipboard.getData();

  if (editorState.selection?.isCollapsed ?? false) {
    await _pasteRichClipboard(editorState, data);
    return;
  }

  // Wait for the selection deletion to finish before pasting so the custom
  // context menu does not race against the editor selection state.
  await deleteSelectedContent(editorState);
  await _pasteRichClipboard(editorState, data);
}


Future<void> _pasteRichClipboard(
  EditorState editorState,
  AppFlowyClipboardData data,
) async {
  if (data.html != null) {
    await pasteHTML(editorState, data.html!);
    return;
  }
  if (data.text != null) {
    await handlePastePlainText(editorState, data.text!);
    return;
  }
}

bool _isNodeInsideTable(Node node) {
  Node? current = node;
  while (current != null) {
    if (current.type == 'table') {
      return true;
    }
    current = current.parent;
  }

  return false;
}

/// 2. delete selected content
void handleCut(EditorState editorState) {
  handleCopy(editorState);
  deleteSelectedContent(editorState);
}

Future<void> deleteSelectedContent(EditorState editorState) async {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return;
  }
  final transaction = editorState.transaction;
  if (selection.isCollapsed) {
    // if the selection is collapsed, delete the current node
    final node = editorState.getNodeAtPath(selection.end.path);
    if (node == null || _isNodeInsideTable(node)) {
      return;
    }
    transaction.deleteNode(node);
    final nextNode = node.next;
    if (nextNode != null && nextNode.delta != null) {
      transaction.afterSelection = Selection.collapsed(
        Position(path: node.path, offset: nextNode.delta?.length ?? 0),
      );
    }
  } else {
    // if the selection is not collapsed, delete the selection
    await editorState.deleteSelection(selection);
    transaction.afterSelection = Selection.collapsed(selection.start);
  }

  await editorState.apply(transaction);
}
