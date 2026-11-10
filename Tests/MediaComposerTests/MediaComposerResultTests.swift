import MediaComposer
import Testing

struct MediaComposerResultTests {
  @Test(arguments: [MediaComposerResult.Source.camera, .library, .clipboard])
  func resultKeepsTheSourceItWasMadeWith(source: MediaComposerResult.Source) {
    let result = MediaComposerResult(images: [], caption: nil, coordinates: nil, source: source)

    #expect(result.source == source)
  }

  @Test
  func sourcesAreCameraLibraryAndClipboard() {
    let names = [MediaComposerResult.Source.camera, .library, .clipboard].map(Self.name(of:))

    #expect(names == ["camera", "library", "clipboard"])
  }

  private static func name(of source: MediaComposerResult.Source) -> String {
    switch source {
    case .camera: "camera"
    case .library: "library"
    case .clipboard: "clipboard"
    }
  }
}
