import CoreLocation
import SwiftUI
import UIKit

public struct MediaComposerView: View {
    private let configuration: MediaComposerConfiguration
    private let onSend: (MediaComposerResult) -> Void
    private let onCancel: () -> Void

    @State private var viewModel: MediaComposerViewModel
    @State private var caption = ""
    @State private var showCamera = false

    public init(
        configuration: MediaComposerConfiguration = .default,
        onSend: @escaping (MediaComposerResult) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.configuration = configuration
        self.onSend = onSend
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

                if configuration.captionMode != .none {
                    CaptionInputView(
                        caption: $caption,
                        selectionCount: viewModel.selectedAssetIDs.count,
                        isSendEnabled: isSendEnabled,
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
                }

                ToolbarItem(placement: .principal) {
                    albumSelector
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.selectedAssetIDs.count > 0 {
                        selectionBadge
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            await viewModel.requestAuthorization()
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                let result = MediaComposerResult(images: [image], caption: captionToSend, coordinates: nil)
                onSend(result)
            }
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
        HStack {
            Spacer()
            Button(action: handleSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(isSendEnabled ? .blue : .gray)
            }
            .disabled(!isSendEnabled)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }

    // MARK: - Actions

    private func handleSend() {
        Task {
            let images = await viewModel.getSelectedImages()
            guard !images.isEmpty else { return }
            let coordinates = viewModel.getFirstCoordinates()
            let result = MediaComposerResult(images: images, caption: captionToSend, coordinates: coordinates)
            onSend(result)
        }
    }
}
