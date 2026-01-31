# MediaComposer

A flexible Telegram-style media picker for iOS. Combines camera capture and photo gallery selection in a single sheet interface.

## Features

- Live camera preview cell with instant capture
- Photo gallery grid with smooth scrolling
- Single or multiple photo selection
- Optional caption input
- Localized in 29 languages
- iOS 17+, Swift 5.9+

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "git@github.com:botforge-pro/MediaComposer.git", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → paste the repository URL.

## Usage

### Basic Usage

```swift
import MediaComposer

struct ContentView: View {
    @State private var showComposer = false

    var body: some View {
        Button("Select Photo") {
            showComposer = true
        }
        .sheet(isPresented: $showComposer) {
            MediaComposerView { images, caption in
                // Handle selected images and optional caption
                print("Selected \(images.count) images")
                if let caption {
                    print("Caption: \(caption)")
                }
                showComposer = false
            } onCancel: {
                showComposer = false
            }
        }
    }
}
```

### Configuration

MediaComposer is highly configurable to fit different use cases:

```swift
let config = MediaComposerConfiguration(
    showCamera: true,      // Show/hide camera cell
    maxSelection: 5,       // Maximum photos to select (1-10)
    captionMode: .optional // .none, .optional, or .required
)

MediaComposerView(configuration: config) { images, caption in
    // ...
} onCancel: {
    // ...
}
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `showCamera` | `Bool` | `true` | Show live camera preview cell |
| `maxSelection` | `Int` | `1` | Maximum number of photos (1+) |
| `captionMode` | `CaptionMode` | `.optional` | Caption input behavior |

### Caption Modes

- `.none` — No caption input shown
- `.optional` — Caption input shown, send enabled without caption
- `.required` — Caption input shown, send disabled until caption entered

### Presets

```swift
// Default: single photo, optional caption, camera enabled
MediaComposerView(configuration: .default) { ... }

// Photo only: single photo, no caption
MediaComposerView(configuration: .photoOnly) { ... }

// Gallery only: no camera cell
MediaComposerView(configuration: .galleryOnly) { ... }

// Multiple photos
MediaComposerView(configuration: .multiplePhotos(max: 10)) { ... }
```

## Localization

Supports 29 languages out of the box:
- English, Russian, German, French, Spanish, Italian, Portuguese
- Chinese (Simplified, Traditional, Hong Kong), Japanese, Korean
- Arabic, Turkish, Polish, Dutch, Swedish, Norwegian, Danish, Finnish
- Greek, Thai, Vietnamese, Indonesian, Ukrainian, Serbian (Cyrillic & Latin)

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Privacy

Add to your `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Select photos to share</string>
<key>NSCameraUsageDescription</key>
<string>Take photos to share</string>
```

## License

MIT
