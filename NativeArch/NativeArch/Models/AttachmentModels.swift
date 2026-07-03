import Foundation

/// A timestamped progress-log entry on an experiment (lab-notebook style).
struct ExperimentUpdate: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var experimentId: String = ""
    var happenedAt: Date = Date()
    var note: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
}

/// Metadata for an attached image. The bytes live in `image_blobs` (loaded on
/// demand), never in this struct.
struct AttachedImage: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var experimentId: String?
    var updateId: String?
    var caption: String = ""
    var notes: String = ""
    var contentType: String = "image/jpeg"
    var createdAt: Date = Date()
}
