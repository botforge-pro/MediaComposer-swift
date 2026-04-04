import CoreLocation
import ImageIO
import SwiftUI
import UIKit

public struct MediaComposerView: View {
    private let configuration: MediaComposerConfiguration
    private let onSend: (MediaComposerResult) -> Void
    private let onError: (Error) -> Void
    private let onCancel: () -> Void

    @State private var viewModel: MediaComposerViewModel
    @State private var caption = ""
    @State private var showCamera = false
    @State private var isSending = false
    @State private var pastedImage: UIImage?
    @State private var pastedCoordinates: CLLocationCoordinate2D?

    public init(
        configuration: MediaComposerConfiguration = .default,
        onSend: @escaping (MediaComposerResult) -> Void,
        onError: @escaping (Error) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.onSend = onSend
        self.onError = onError
        self.onCancel = onCancel
        self._viewModel = State(initialValue: MediaComposerViewModel(maxSelection: configuration.maxSelection))
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PhotoGridView(
                    viewModel: viewModel,
                    showCameraCell: configuration.showCamera,
                    onCameraTap: { showCamera = true }
                )
                .allowsHitTesting(!isSending)

                if configuration.captionMode != .none {
                    CaptionInputView(
                        caption: $caption,
                        selectionCount: viewModel.selectedAssetIDs.count,
                        isSendEnabled: isSendEnabled,
                        isSending: isSending,
                        onSend: handleSend
                    )
                } else {
                    bottomBar
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .frame(width: 36, height: 36)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(isSending)
                }

                ToolbarItem(placement: .principal) {
                    albumSelector
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.selectedAssetIDs.count > 0 {
                        selectionBadge
                    } else {
                        Button(action: handlePaste) {
                            Image(systemName: "doc.on.clipboard")
                                .fontWeight(.semibold)
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(isSending)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(isSending)
        .task {
            await viewModel.requestAuthorization()
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                let result = MediaComposerResult(images: [image], caption: captionToSend, coordinates: nil)
                onSend(result)
            }
        }
        .sheet(item: Binding(
            get: { pastedImage.map { PastedImage(image: $0) } },
            set: { if $0 == nil { pastedImage = nil } }
        )) { pasted in
            ClipboardPreviewSheet(
                image: pasted.image,
                onSend: {
                    let result = MediaComposerResult(images: [pasted.image], caption: captionToSend, coordinates: pastedCoordinates)
                    pastedImage = nil
                    pastedCoordinates = nil
                    onSend(result)
                },
                onCancel: { pastedImage = nil }
            )
        }
    }

    // MARK: - Computed Properties

    private var isSendEnabled: Bool {
        guard viewModel.selectedAssetIDs.count > 0 else { return false }

        switch configuration.captionMode {
        case .none, .optional:
            return true
        case .required:
            return !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private var captionToSend: String? {
        switch configuration.captionMode {
        case .none:
            return nil
        case .optional, .required:
            let trimmed = caption.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
    }

    // MARK: - Subviews

    private var albumSelector: some View {
        Menu {
            Button(L10n.mediaComposerAlbumRecent) {}
        } label: {
            HStack(spacing: 4) {
                Text(L10n.mediaComposerAlbumRecent)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.down")
                    .font(.caption.bold())
            }
            .foregroundStyle(.primary)
        }
    }

    private var selectionBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "checkmark")
                .font(.caption.bold())
            Text("\(viewModel.selectedAssetIDs.count)")
                .font(.subheadline.bold())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.blue)
        .clipShape(Capsule())
    }

    private var bottomBar: some View {
        Button(action: handleSend) {
            Group {
                if isSending {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(L10n.mediaComposerSend)
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSendEnabled && !isSending ? .blue : .gray)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!isSendEnabled || isSending)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }

    // MARK: - Actions

    private func handlePaste() {
        guard let image = UIPasteboard.general.image else {
            onError(MediaComposerError.noImageInClipboard)
            return
        }
        pastedCoordinates = Self.extractGPSFromPasteboard()
        pastedImage = image
    }

    private static func extractGPSFromPasteboard() -> CLLocationCoordinate2D? {
        let imageTypes = ["public.jpeg", "public.png", "public.tiff", "public.heic"]
        for type in imageTypes {
            guard let data = UIPasteboard.general.data(forPasteboardType: type) else { continue }
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { continue }
            guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { continue }
            guard let gps = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any] else { continue }
            guard let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
                  let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double,
                  let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String,
                  let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String
            else { continue }
            let latitude = latRef == "S" ? -lat : lat
            let longitude = lonRef == "W" ? -lon : lon
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return nil
    }

    // MARK: - Send

    private func handleSend() {
        guard !isSending else { return }
        isSending = true
        Task {
            do {
                let images = try await viewModel.getSelectedImages()
                let coordinates = viewModel.getFirstCoordinates()
                let result = MediaComposerResult(images: images, caption: captionToSend, coordinates: coordinates)
                onSend(result)
            } catch {
                isSending = false
                onError(error)
            }
        }
    }
}

// MARK: - Clipboard Preview

private struct PastedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct ClipboardPreviewSheet: View {
    let image: UIImage
    let onSend: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                .navigationTitle(L10n.mediaComposerClipboard)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(L10n.mediaComposerCancel) { onCancel() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(L10n.mediaComposerSend) { onSend() }
                    }
                }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
