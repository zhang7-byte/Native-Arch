import SwiftUI

/// Draw arrows, boxes and text labels over an attached image. Coordinates are
/// stored normalized (0…1) so they render at any size.
struct AnnotateView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    let imageID: String

    @State private var bytes: Data?
    @State private var annotations: [ImageAnnotation] = []
    @State private var tool = "arrow"           // arrow | box | text
    @State private var colorARGB = 0xFFE53935
    @State private var dragStart: CGPoint?
    @State private var dragCurrent: CGPoint?
    @State private var showTextPrompt = false
    @State private var textInput = ""
    @State private var pendingText: CGPoint?

    private let palette = [0xFFE53935, 0xFFFFB300, 0xFF43A047, 0xFF1E88E5, 0xFF000000, 0xFFFFFFFF]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                toolbarRow
                GeometryReader { geo in
                    ZStack {
                        if let bytes, let image = platformImage(from: bytes) {
                            image.resizable().scaledToFit()
                        } else {
                            Color.black.opacity(0.05)
                        }
                        Canvas { ctx, size in
                            for a in annotations { draw(a, in: ctx, size: size) }
                            if let s = dragStart, let c = dragCurrent, tool != "text" {
                                draw(preview(from: s, to: c, size: geo.size), in: ctx, size: size)
                            }
                        }
                        .contentShape(Rectangle())
                        .gesture(drawGesture(in: geo.size))
                    }
                }
            }
            .padding()
            .navigationTitle("Annotate")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem {
                    Button { if !annotations.isEmpty { annotations.removeLast() } } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }.disabled(annotations.isEmpty)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { store.saveAnnotations(imageID, annotations); dismiss() }
                }
            }
            .onAppear {
                bytes = store.imageBytes(imageID)
                annotations = store.annotations(imageID)
            }
            .alert("Label text", isPresented: $showTextPrompt) {
                TextField("Text", text: $textInput)
                Button("Add") {
                    if let p = pendingText, !textInput.isEmpty {
                        annotations.append(ImageAnnotation(type: "text", x1: p.x, y1: p.y,
                            x2: p.x, y2: p.y, text: textInput, color: colorARGB))
                    }
                    textInput = ""
                }
                Button("Cancel", role: .cancel) { textInput = "" }
            }
        }
    }

    private var toolbarRow: some View {
        HStack(spacing: 16) {
            Picker("Tool", selection: $tool) {
                Image(systemName: "arrow.up.right").tag("arrow")
                Image(systemName: "rectangle").tag("box")
                Image(systemName: "textformat").tag("text")
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 220)
            HStack(spacing: 8) {
                ForEach(palette, id: \.self) { c in
                    Circle().fill(Color(argb: c)).frame(width: 22, height: 22)
                        .overlay { Circle().stroke(.primary, lineWidth: colorARGB == c ? 2 : 0) }
                        .onTapGesture { colorARGB = c }
                }
            }
        }
    }

    private func drawGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { v in
                if tool == "text" { return }
                dragStart = dragStart ?? v.startLocation
                dragCurrent = v.location
            }
            .onEnded { v in
                let norm: (CGPoint) -> CGPoint = { CGPoint(x: $0.x / size.width, y: $0.y / size.height) }
                if tool == "text" {
                    pendingText = norm(v.location); showTextPrompt = true
                } else if let s = dragStart {
                    let a = normalizedAnnotation(from: s, to: v.location, size: size)
                    if abs(a.x2 - a.x1) > 0.01 || abs(a.y2 - a.y1) > 0.01 { annotations.append(a) }
                }
                dragStart = nil; dragCurrent = nil
            }
    }

    private func normalizedAnnotation(from s: CGPoint, to e: CGPoint, size: CGSize) -> ImageAnnotation {
        ImageAnnotation(type: tool,
                        x1: s.x / size.width, y1: s.y / size.height,
                        x2: e.x / size.width, y2: e.y / size.height,
                        color: colorARGB)
    }

    private func preview(from s: CGPoint, to c: CGPoint, size: CGSize) -> ImageAnnotation {
        normalizedAnnotation(from: s, to: c, size: size)
    }

    private func draw(_ a: ImageAnnotation, in ctx: GraphicsContext, size: CGSize) {
        let p1 = CGPoint(x: a.x1 * size.width, y: a.y1 * size.height)
        let p2 = CGPoint(x: a.x2 * size.width, y: a.y2 * size.height)
        let color = Color(argb: a.color)
        switch a.type {
        case "box":
            let rect = CGRect(x: min(p1.x, p2.x), y: min(p1.y, p2.y),
                              width: abs(p2.x - p1.x), height: abs(p2.y - p1.y))
            ctx.stroke(Path(roundedRect: rect, cornerRadius: 2), with: .color(color),
                       lineWidth: a.strokeWidth)
        case "text":
            ctx.draw(Text(a.text).font(.headline).foregroundStyle(color),
                     at: p1, anchor: .topLeading)
        default: // arrow
            var path = Path(); path.move(to: p1); path.addLine(to: p2)
            // arrowhead
            let angle = atan2(p2.y - p1.y, p2.x - p1.x)
            let len: CGFloat = 12
            for a2 in [angle + .pi * 0.85, angle - .pi * 0.85] {
                path.move(to: p2)
                path.addLine(to: CGPoint(x: p2.x + cos(a2) * len, y: p2.y + sin(a2) * len))
            }
            ctx.stroke(path, with: .color(color), lineWidth: a.strokeWidth)
        }
    }
}
