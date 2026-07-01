/// Web fallback: no native gzip. The snapshot payload is stored uncompressed.
/// (The lab syncs from desktop + Android, which use the native gzip codec; this
/// just keeps web builds compiling and interoperable with plain payloads.)
List<int> snapDeflate(List<int> bytes) => bytes;

List<int> snapInflate(List<int> bytes) {
  if (bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
    throw UnsupportedError(
        'This snapshot is gzip-compressed; open it on a desktop or mobile build.');
  }
  return bytes;
}
