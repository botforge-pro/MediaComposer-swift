import Photos
import SwiftUI
import UIKit

@MainActor
@Observable
final class MediaComposerViewModel {
    // MARK: - Public State

    private(set) var assets: [PHAsset] = []
    private(set) var thumbnails: [String: UIImage] = [:]
    private(set) var selectedAssetIDs: [String] = []
    private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined
    private(set) var hasMoreAssets = true

    let maxSelection: Int

    // MARK: - Private

    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 200, height: 200)
    private let pageSize = 50
    private var fetchResult: PHFetchResult<PHAsset>?

    // MARK: - Init

    init(maxSelection: Int = 1) {
        self.maxSelection = maxSelection
    }

    // MARK: - Public Methods

    func requestAuthorization() async {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        authorizationStatus = status

        if status == .authorized || status == .limited {
            loadInitialAssets()
        }
    }

    func loadMoreIfNeeded(currentAsset: PHAsset) {
        guard hasMoreAssets else { return }
        guard let lastAsset = assets.last else { return }

        if currentAsset.localIdentifier == lastAsset.localIdentifier {
            loadMoreAssets()
        }
    }

    func toggleSelection(asset: PHAsset) {
        let id = asset.localIdentifier

        if let index = selectedAssetIDs.firstIndex(of: id) {
            selectedAssetIDs.remove(at: index)
        } else if selectedAssetIDs.count < maxSelection {
            selectedAssetIDs.append(id)
        } else if maxSelection == 1 {
            selectedAssetIDs = [id]
        }
    }

    func isSelected(asset: PHAsset) -> Bool {
        selectedAssetIDs.contains(asset.localIdentifier)
    }

    func selectionIndex(asset: PHAsset) -> Int? {
        guard let index = selectedAssetIDs.firstIndex(of: asset.localIdentifier) else {
            return nil
        }
        return index + 1
    }

    func loadThumbnail(for asset: PHAsset) {
        let id = asset.localIdentifier
        guard thumbnails[id] == nil else { return }

        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic

        imageManager.requestImage(
            for: asset,
            targetSize: thumbnailSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, _ in
            guard let image else { return }
            Task { @MainActor in
                self?.thumbnails[id] = image
            }
        }
    }

    func loadFullImage(for asset: PHAsset) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false

        return await withCheckedContinuation { continuation in
            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if !isDegraded {
                    continuation.resume(returning: image)
                }
            }
        }
    }

    func getSelectedImages() async -> [UIImage] {
        var images: [UIImage] = []

        for id in selectedAssetIDs {
            guard let asset = assets.first(where: { $0.localIdentifier == id }) else { continue }
            if let image = await loadFullImage(for: asset) {
                images.append(image)
            }
        }

        return images
    }

    func getFirstCoordinates() -> (latitude: Double, longitude: Double)? {
        for id in selectedAssetIDs {
            guard let asset = assets.first(where: { $0.localIdentifier == id }),
                  let location = asset.location else { continue }
            return (location.coordinate.latitude, location.coordinate.longitude)
        }
        return nil
    }

    // MARK: - Private Methods

    private func loadInitialAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        loadMoreAssets()
    }

    private func loadMoreAssets() {
        guard let fetchResult else { return }

        let startIndex = assets.count
        let endIndex = min(startIndex + pageSize, fetchResult.count)

        guard startIndex < endIndex else {
            hasMoreAssets = false
            return
        }

        var newAssets: [PHAsset] = []
        for i in startIndex..<endIndex {
            newAssets.append(fetchResult.object(at: i))
        }

        assets.append(contentsOf: newAssets)
        hasMoreAssets = endIndex < fetchResult.count
    }
}
