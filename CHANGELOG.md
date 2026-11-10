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
- When camera access is denied, the camera tile shows a crossed-out camera and opens your app's
  settings when tapped. Before the user has been asked, the tile stays dark and the camera asks
  for access when it opens.
- `MediaComposerError.cameraUnavailable` is passed to `onError` when camera access is granted but
  the camera tile still cannot show the camera, for example when another app holds the camera.
  Its description is the system's own, in the user's language. On a device without a camera,
  such as the simulator, the tile stays dark without an error. If you `switch` over
  `MediaComposerError` without a `default`, add this case.

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
