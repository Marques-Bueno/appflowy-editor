import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppFlowyClipboardData {
  const AppFlowyClipboardData({
    this.text,
    this.html,
  });
  final String? text;
  final String? html;
}

class AppFlowyClipboard {
  static AppFlowyClipboardData? _mockData;
  static AppFlowyClipboardData? _memoryData;

  @visibleForTesting
  static String? lastText;

  static Future<void> setData({
    String? text,
    String? html,
  }) async {
    if (text == null && html == null) {
      return;
    }

    _memoryData = AppFlowyClipboardData(text: text, html: html);
    if (text == null) {
      return;
    }

    lastText = text;

    return Clipboard.setData(
      ClipboardData(
        text: text,
      ),
    );
  }

  static Future<AppFlowyClipboardData> getData() async {
    if (_mockData != null) {
      return _mockData!;
    }

    final data = await Clipboard.getData(Clipboard.kTextPlain);

    // Flutter exposes text through the system clipboard. When the text still
    // matches the last write from this process, preserve the richer HTML
    // value as well. If another application changed the clipboard, use the
    // current system value instead of returning stale data.
    if (_memoryData != null && data?.text == _memoryData!.text) {
      return _memoryData!;
    }

    return AppFlowyClipboardData(
      text: data?.text,
      html: null,
    );
  }

  @visibleForTesting
  static void mockSetData(AppFlowyClipboardData? data) {
    _mockData = data;
    if (data == null) {
      _memoryData = null;
    }
  }
}
