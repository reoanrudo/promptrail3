//
//  StorageManager.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    private let storage: Storage

    init(bucketURL: String = "gs://prompt-manebu.firebasestorage.app") {
        self.storage = Storage.storage(url: bucketURL)
    }

    func uploadImage(data: Data, folder: String = "imagePrompts") async throws -> String {
        let fileName = "\(UUID().uuidString).jpg"
        let reference = storage.reference().child("\(folder)/\(fileName)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.putData(data, metadata: metadata) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        let url = try await reference.downloadURL()
        return url.absoluteString
    }
}
