import 'dart:typed_data';

/// Web has no filesystem path to write to — `FilePicker.saveFile(bytes: …)`
/// already triggers the browser download, so this is a no-op.
Future<void> writeBytes(String path, Uint8List bytes) async {}
