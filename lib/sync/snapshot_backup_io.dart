import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Writes the about-to-be-overwritten data to a timestamped file in the app's
/// documents directory, so a bad download is always recoverable. Best-effort:
/// returns the path, or null if it couldn't be written.
Future<String?> savePresyncBackup(String json, String stamp) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/labtrack-presync-$stamp.json');
    await file.writeAsString(json);
    return file.path;
  } catch (_) {
    return null;
  }
}
