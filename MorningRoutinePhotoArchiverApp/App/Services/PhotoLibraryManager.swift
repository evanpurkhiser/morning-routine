import Photos
import UIKit

final class PhotoLibraryManager {
    private var albumIdsByName: [String: String] = [:]

    func requestAddOnlyPermission() async -> Bool {
        let status = await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
        switch status {
        case .authorized, .limited:
            return true
        default:
            return false
        }
    }

    func ensureAlbumsExist() async {
        for angle in CaptureAngle.allCases {
            let id = await ensureAlbum(named: angle.albumName)
            if let id {
                albumIdsByName[angle.albumName] = id
            }
        }
    }

    func savePhoto(_ data: Data, toAlbumNamed albumName: String) async {
        guard let collection = fetchAlbum(named: albumName) ?? await fetchOrCreateAlbum(named: albumName) else {
            return
        }

        guard let image = UIImage(data: data) else { return }

        do {
            try await performChanges {
                let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                guard
                    let placeholder = creationRequest.placeholderForCreatedAsset,
                    let albumRequest = PHAssetCollectionChangeRequest(for: collection)
                else {
                    return
                }

                let assets = NSArray(array: [placeholder])
                albumRequest.addAssets(assets)
            }
        } catch {
            return
        }
    }

    private func ensureAlbum(named name: String) async -> String? {
        if let existing = fetchAlbum(named: name) {
            return existing.localIdentifier
        }
        return await createAlbum(named: name)
    }

    private func fetchOrCreateAlbum(named name: String) async -> PHAssetCollection? {
        if let existing = fetchAlbum(named: name) {
            return existing
        }

        guard let id = await createAlbum(named: name) else {
            return nil
        }

        let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [id], options: nil)
        return result.firstObject
    }

    private func fetchAlbum(named name: String) -> PHAssetCollection? {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "title = %@", name)
        let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
        return result.firstObject
    }

    private func createAlbum(named name: String) async -> String? {
        do {
            var localIdentifier: String?
            try await performChanges {
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                localIdentifier = request.placeholderForCreatedAssetCollection.localIdentifier
            }
            return localIdentifier
        } catch {
            return nil
        }
    }

    private func performChanges(_ block: @escaping () -> Void) async throws {
        try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges(block) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                if success {
                    continuation.resume(returning: ())
                } else {
                    continuation.resume(throwing: PhotoLibraryError.operationFailed)
                }
            }
        }
    }
}

enum PhotoLibraryError: Error {
    case operationFailed
}
