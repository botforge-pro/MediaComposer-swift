import Foundation

/// Configuration for MediaComposer behavior
public struct MediaComposerConfiguration: Sendable {
  /// Camera cell visibility
  public let showCamera: Bool

  /// Maximum number of photos that can be selected
  public let maxSelection: Int

  /// Caption input mode
  public let captionMode: CaptionMode

  /// Caption input mode options
  public enum CaptionMode: Sendable {
    /// No caption input shown
    case none
    /// Caption is optional (send button enabled without caption)
    case optional
    /// Caption is required (send button disabled until caption entered)
    case required
  }

  public init(
    showCamera: Bool = true,
    maxSelection: Int = 1,
    captionMode: CaptionMode = .optional
  ) {
    self.showCamera = showCamera
    self.maxSelection = max(1, maxSelection)
    self.captionMode = captionMode
  }
}

// MARK: - Presets

extension MediaComposerConfiguration {
  /// Single photo with optional caption (default Telegram-like behavior)
  public static let `default` = MediaComposerConfiguration()

  /// Single photo, no caption
  public static let photoOnly = MediaComposerConfiguration(captionMode: .none)

  /// Multiple photos with optional caption
  public static func multiplePhotos(max: Int) -> MediaComposerConfiguration {
    MediaComposerConfiguration(maxSelection: max, captionMode: .optional)
  }

  /// Gallery only (no camera), single selection
  public static let galleryOnly = MediaComposerConfiguration(showCamera: false)
}
