import Foundation

/// A drawn markup on an image. Coordinates are normalized 0…1 relative to the
/// image, so they survive any display size. JSON keys match the Flutter app.
struct ImageAnnotation: Codable, Identifiable, Hashable {
    var id = UUID()
    var type: String = "arrow"   // arrow | box | text
    var x1: Double = 0
    var y1: Double = 0
    var x2: Double = 0
    var y2: Double = 0
    var text: String = ""
    var color: Int = 0xFFE53935  // red
    var strokeWidth: Double = 3

    enum CodingKeys: String, CodingKey {
        case type, x1, y1, x2, y2, text, color, strokeWidth
    }
}

func encodeAnnotations(_ list: [ImageAnnotation]) -> String {
    guard let data = try? JSONEncoder().encode(list),
          let s = String(data: data, encoding: .utf8) else { return "[]" }
    return s
}

func decodeAnnotations(_ raw: String) -> [ImageAnnotation] {
    guard let data = raw.data(using: .utf8),
          let list = try? JSONDecoder().decode([ImageAnnotation].self, from: data) else { return [] }
    return list
}
