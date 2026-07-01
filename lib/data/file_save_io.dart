import 'dart:io';
import 'dart:typed_data';

/// On desktop/mobile, `FilePicker.saveFile` returns the chosen path; we write
/// the bytes there.
Future<void> writeBytes(String path, Uint8List bytes) =>
    File(path).writeAsBytes(bytes);
