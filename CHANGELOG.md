# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-11-10

The first tagged release. Requires iOS 17 and Swift 6. Add the package by version:
`.package(url: "https://github.com/botforge-pro/MediaComposer-swift.git", from: "1.0.0")`.
Your app's Info.plist needs `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`.

### Added

- `MediaComposerView`: a sheet for picking photos. The first tile of its grid shows what the
  camera sees and opens the camera when tapped; the other tiles are the photo library. A toolbar
  button pastes an image from the clipboard, and an optional field adds a caption.
  `MediaComposerView` takes three handlers: `onSend`, `onError` and `onCancel`.
- `MediaComposerConfiguration` sets whether the camera tile is shown, how many photos can be
  picked and whether a caption is off, optional or required. Presets:
  - `.default`: camera tile, one photo, optional caption;
  - `.photoOnly`: camera tile, one photo, no caption;
  - `.galleryOnly`: no camera tile, one photo, optional caption;
  - `.multiplePhotos(max:)`: camera tile, up to `max` photos, optional caption.
- `onSend` receives a `MediaComposerResult`: the images, the caption, and `coordinates`, the place
  where the photo was taken when its metadata has one; a camera photo has none.
- `MediaComposerResult.source` says where the images came from: `.camera`, `.library` or
  `.clipboard`. One result never mixes sources. A photo from the camera is not in the photo library yet, so if your app keeps a
  copy of new photos there, save it only when `source == .camera`.
- `MediaComposerError.cameraUnavailable` is passed to `onError` when the camera tile cannot show
  the camera, for example when camera access is denied. The tile then stays black. Tell the user
  why and offer a way to your app's settings. On a device without a camera, such as the
  simulator, the tile stays black without an error.

### Changed

- `MediaComposerResult.init` requires `source:`. This matters only if you used the package before
  this release, by branch or commit, and create results yourself, for example in tests:

  Before:

  ```swift
  MediaComposerResult(images: images, caption: nil, coordinates: nil)
  ```

  After:

  ```swift
  MediaComposerResult(images: images, caption: nil, coordinates: nil, source: .library)
  ```

[1.0.0]: https://github.com/botforge-pro/MediaComposer-swift/releases/tag/1.0.0
