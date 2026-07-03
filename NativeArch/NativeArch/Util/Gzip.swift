import Foundation
import Compression

enum Gzip {
    /// True if the data starts with the gzip magic bytes.
    static func isGzip(_ data: Data) -> Bool {
        data.count >= 2 && data[data.startIndex] == 0x1f && data[data.startIndex + 1] == 0x8b
    }

    /// Decompress a standard gzip stream (10-byte header, raw DEFLATE body,
    /// 8-byte trailer whose last 4 bytes are the uncompressed size).
    static func gunzip(_ data: Data) -> Data? {
        guard isGzip(data), data.count > 18 else { return nil }
        let body = data.subdata(in: (data.startIndex + 10)..<(data.endIndex - 8))
        // ISIZE (uncompressed size mod 2^32), little-endian.
        let isize = data.subdata(in: (data.endIndex - 4)..<data.endIndex)
            .reduce(0) { ($0 << 8) | Int($1) }  // read below in LE order
        var size = 0
        for (i, b) in data.suffix(4).enumerated() { size |= Int(b) << (8 * i) }
        _ = isize
        let capacity = size > 0 ? size : max(body.count * 8, 65_536)
        var dst = Data(count: capacity)
        let written = dst.withUnsafeMutableBytes { d -> Int in
            body.withUnsafeBytes { s -> Int in
                compression_decode_buffer(
                    d.bindMemory(to: UInt8.self).baseAddress!, capacity,
                    s.bindMemory(to: UInt8.self).baseAddress!, body.count,
                    nil, COMPRESSION_ZLIB)
            }
        }
        guard written > 0 else { return nil }
        return dst.prefix(written)
    }
}
