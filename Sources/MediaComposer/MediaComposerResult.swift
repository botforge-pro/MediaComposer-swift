import CoreLocation
import UIKit

public enum MediaComposerError: LocalizedError {
    case noImageInClipboard

    public var errorDescription: String? {
        switch self {
        case .noImageInClipboard:
            return "No image in clipboard"
        }
    }
}

public struct MediaComposerResult {
    public enum Source: Sendable, Equatable {
        case camera
        case library
        case clipboard
    }

    public let images: [UIImage]
    public let caption: String?
    public let coordinates: CLLocationCoordinate2D?
    public let source: Source

    public init(
        images: [UIImage], caption: String?, coordinates: CLLocationCoordinate2D?, source: Source
    ) {
        self.images = images
        self.caption = caption
        self.coordinates = coordinates
        self.source = source
    }

    public var firstImage: UIImage? {
        images.first
    }

    public var hasCaption: Bool {
        guard let caption else { return false }
        return !caption.isEmpty
    }

    public var hasCoordinates: Bool {
        coordinates != nil
    }
}
