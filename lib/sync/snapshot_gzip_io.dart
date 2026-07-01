import 'dart:io';

/// Native gzip (desktop + mobile). The snapshot payload is gzip-compressed before
/// base64 + upload, and inflated on download.
List<int> snapDeflate(List<int> bytes) => gzip.encode(bytes);

List<int> snapInflate(List<int> bytes) {
  // Auto-detect: gzip streams start with the magic bytes 0x1f 0x8b.
  if (bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
    return gzip.decode(bytes);
  }
  return bytes; // already plain (e.g. uploaded by a web client)
}
