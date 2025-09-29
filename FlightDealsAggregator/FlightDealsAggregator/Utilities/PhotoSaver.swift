//
//  PhotoSaver.swift
//  FlightDealsAggregator
//

import UIKit
import Photos

enum PhotoSaver {
    static func saveToPhotos(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw NSError(domain: "PhotoSaver", code: 1, userInfo: [NSLocalizedDescriptionKey: "Photo Library access denied"])
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                if let error = error { continuation.resume(throwing: error); return }
                if success { continuation.resume(returning: ()) } else {
                    continuation.resume(throwing: NSError(domain: "PhotoSaver", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unknown save failure"]))
                }
            })
        }
    }
}


