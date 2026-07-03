import Foundation

/// Minimal RFC-4180-ish CSV encode/parse (handles quotes, commas, newlines).
enum CSV {
    static func field(_ s: String) -> String {
        if s.contains(",") || s.contains("\"") || s.contains("\n") {
            return "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return s
    }

    static func encode(_ rows: [[String]]) -> String {
        rows.map { $0.map(field).joined(separator: ",") }.joined(separator: "\n")
    }

    static func parse(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var inQuotes = false
        let chars = Array(text)
        var i = 0
        func endField() { row.append(field); field = "" }
        func endRow() { endField(); rows.append(row); row = [] }
        while i < chars.count {
            let c = chars[i]
            if inQuotes {
                if c == "\"" {
                    if i + 1 < chars.count && chars[i + 1] == "\"" { field.append("\""); i += 1 }
                    else { inQuotes = false }
                } else { field.append(c) }
            } else {
                switch c {
                case "\"": inQuotes = true
                case ",": endField()
                case "\n": endRow()
                case "\r": break
                default: field.append(c)
                }
            }
            i += 1
        }
        if !field.isEmpty || !row.isEmpty { endRow() }
        return rows.filter { !($0.count == 1 && $0[0].isEmpty) }
    }
}
