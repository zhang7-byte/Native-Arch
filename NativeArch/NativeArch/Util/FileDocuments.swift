import SwiftUI
import UniformTypeIdentifiers

/// A CSV file document for `.fileExporter`.
struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText, .plainText] }
    var text: String
    init(text: String = "") { self.text = text }
    init(configuration: ReadConfiguration) throws {
        text = configuration.file.regularFileContents.map { String(decoding: $0, as: UTF8.self) } ?? ""
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

/// A PDF file document for `.fileExporter`.
struct PDFFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    var data: Data
    init(data: Data = Data()) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
