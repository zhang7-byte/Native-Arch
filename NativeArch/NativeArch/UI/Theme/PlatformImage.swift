import SwiftUI

#if canImport(UIKit)
import UIKit
func platformImage(from data: Data) -> Image? {
    guard let ui = UIImage(data: data) else { return nil }
    return Image(uiImage: ui)
}
#elseif canImport(AppKit)
import AppKit
func platformImage(from data: Data) -> Image? {
    guard let ns = NSImage(data: data) else { return nil }
    return Image(nsImage: ns)
}
#endif
