import SwiftUI

/// Renders a SwiftUI view to a single-page US-Letter PDF (612×792 pt).
@MainActor
func renderPDF<V: View>(_ view: V, size: CGSize = CGSize(width: 612, height: 792)) -> Data {
    let renderer = ImageRenderer(content:
        view.frame(width: size.width, height: size.height, alignment: .topLeading)
            .background(Color.white)
    )
    let pdf = NSMutableData()
    renderer.render { _, renderInContext in
        var box = CGRect(origin: .zero, size: size)
        guard let consumer = CGDataConsumer(data: pdf as CFMutableData),
              let ctx = CGContext(consumer: consumer, mediaBox: &box, nil) else { return }
        ctx.beginPDFPage(nil)
        renderInContext(ctx)
        ctx.endPDFPage()
        ctx.closePDF()
    }
    return pdf as Data
}
