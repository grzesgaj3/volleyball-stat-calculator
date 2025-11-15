import 'dart:typed_data';
import 'dart:html' as html;

/// Triggers a browser download for [bytes] with the provided [filename].
/// Returns null because there is no filesystem path on the web.
Future<String?> saveFile(Uint8List bytes, String filename) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = filename;

  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  return null;
}
