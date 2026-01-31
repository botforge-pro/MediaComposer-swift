import AVFoundation
import Photos
import SwiftUI
import UIKit

struct PhotoGridView: View {
    @Bindable var viewModel: MediaComposerViewModel
    let showCameraCell: Bool
    let onCameraTap: () -> Void

    private let spacing: CGFloat = 2

    private var cellSize: CGFloat {
        (UIScreen.main.bounds.width - spacing * 2) / 3
    }

    var body: some View {
        ScrollView {
            VStack(spacing: spacing) {
                if showCameraCell {
                    topSectionWithCamera
                    photosGrid(startingAt: 4)
                } else {
                    photosGrid(startingAt: 0)
                }
            }
        }
    }

    // MARK: - Top Section with Camera

    private var topSectionWithCamera: some View {
        HStack(spacing: spacing) {
            CameraPreviewCell(onTap: onCameraTap)
                .frame(width: cellSize, height: cellSize * 2 + spacing)

            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    photoCell(at: 0)
                    photoCell(at: 1)
                }
                HStack(spacing: spacing) {
                    photoCell(at: 2)
                    photoCell(at: 3)
                }
            }
        }
    }

    // MARK: - Photos Grid

    private func photosGrid(startingAt offset: Int) -> some View {
        let photos = Array(viewModel.assets.dropFirst(offset))
        let columns = [
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing)
        ]

        return LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(photos, id: \.localIdentifier) { asset in
                photoCellView(for: asset)
                    .frame(height: cellSize)
            }
        }
    }

    // MARK: - Photo Cells

    @ViewBuilder
    private func photoCell(at index: Int) -> some View {
        if index < viewModel.assets.count {
            photoCellView(for: viewModel.assets[index])
                .frame(width: cellSize, height: cellSize)
        } else {
            Color.gray.opacity(0.2)
                .frame(width: cellSize, height: cellSize)
        }
    }

    @ViewBuilder
    private func photoCellView(for asset: PHAsset) -> some View {
        let thumbnail = viewModel.thumbnails[asset.localIdentifier]

        if let thumbnail {
            PhotoCell(
                image: thumbnail,
                isSelected: viewModel.isSelected(asset: asset),
                selectionIndex: viewModel.selectionIndex(asset: asset),
                onTap: { viewModel.toggleSelection(asset: asset) }
            )
        } else {
            Color.gray.opacity(0.3)
                .onAppear {
                    viewModel.loadThumbnail(for: asset)
                }
        }
    }
}

// MARK: - Camera Preview Cell

private struct CameraPreviewCell: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                CameraPreviewView()

                Image(systemName: "camera.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.black.opacity(0.5))
                    .clipShape(Circle())
                    .padding(8)
            }
        }
        .buttonStyle(.plain)
        .clipped()
    }
}

// MARK: - Camera Preview UIViewRepresentable

private struct CameraPreviewView: UIViewRepresentable {
    func makeUIView(context: Context) -> CameraPreviewUIView {
        CameraPreviewUIView()
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {}
}

private final class CameraPreviewUIView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var sessionManager: CameraSessionManager?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupCamera()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    private func setupCamera() {
        let manager = CameraSessionManager()
        sessionManager = manager

        guard let session = manager.configure() else { return }

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        layer.addSublayer(preview)
        previewLayer = preview

        manager.start()
    }
}

// MARK: - Camera Session Manager

private final class CameraSessionManager {
    private var session: AVCaptureSession?

    func configure() -> AVCaptureSession? {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return nil
        }

        let newSession = AVCaptureSession()
        newSession.beginConfiguration()
        newSession.sessionPreset = .medium

        if newSession.canAddInput(input) {
            newSession.addInput(input)
        }

        newSession.commitConfiguration()
        session = newSession

        return newSession
    }

    func start() {
        guard let session else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }

    func stop() {
        guard let session else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            session.stopRunning()
        }
    }
}
