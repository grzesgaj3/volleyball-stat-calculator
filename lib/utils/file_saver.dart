// Platform-aware file saver. Uses conditional exports to pick
// the correct implementation for web vs IO platforms.
export 'file_saver_io.dart'
  if (dart.library.html) 'file_saver_web.dart';
