import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Saves [bytes] to a file named [filename] inside the
/// application documents directory and returns the saved file path.
Future<String> saveFile(Uint8List bytes, String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$filename');
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);
  return file.path;
}
