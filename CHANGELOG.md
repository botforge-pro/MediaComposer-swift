# Changelog

All notable changes to this project are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-11-10

The first tagged release. Add the package by version from now on:
`.package(url: "https://github.com/botforge-pro/MediaComposer-swift.git", from: "1.0.0")`.

### Added

- `MediaComposerView`: a Telegram-style sheet with a live camera cell, the photo library grid,
  paste from the clipboard and an optional caption.
- `MediaComposerConfiguration` with the `.default`, `.photoOnly`, `.galleryOnly` and
  `.multiplePhotos(max:)` presets.
- `MediaComposerResult.source` says where the images came from: `.camera`, `.library` or
  `.clipboard`. Only a camera photo is new to the device, so it is the one to check before
  saving a copy to the photo library.
- `MediaComposerError.cameraUnavailable` reaches `onError` when the live camera cell cannot open
  the camera, for example when camera access is denied. The cell then stays black; offer the
  user a way to the app's settings. A device without a camera is not an error.

### Changed

- `MediaComposerResult.init` requires `source:`. If you built against an untagged revision and
  create results yourself, for example in tests, pass the source:

  Before:

  ```swift
  MediaComposerResult(images: images, caption: nil, coordinates: nil)
  ```

  After:

  ```swift
  MediaComposerResult(images: images, caption: nil, coordinates: nil, source: .library)
  ```

[1.0.0]: https://github.com/botforge-pro/MediaComposer-swift/releases/tag/1.0.0
