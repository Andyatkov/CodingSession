//
//  PhotosProvider.swift
//  CodingSession
//
//  Created by ADyatkov on 21.11.2023.
//

import Photos
import Combine
import UIKit

final class PhotosProvider {

    private let manager = PHImageManager.default()

    private func checkPermissionsStatus() -> AnyPublisher<Void, UIError> {
        return Future<Void, UIError> { promise in
            PHPhotoLibrary.requestAuthorization() { (status) -> Void in
                switch status {
                case .authorized, .limited:
                    promise(.success(()))
                case .denied, .restricted:
                    promise(.failure(.noAccessPhoto))
                case .notDetermined:
                    promise(.success(()))
                @unknown default:
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func fetchAssets() -> AnyPublisher<[PHAsset], UIError> {
        return Future<[PHAsset], UIError> { resolve in
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: Constants.fetchOptionsPredicate, PHAssetMediaType.video.rawValue)

            let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
            var videoAssets: [PHAsset] = []

            fetchResult.enumerateObjects { (asset, _, _) in
                videoAssets.append(asset)
            }
            resolve(.success(videoAssets))
        }
        .eraseToAnyPublisher()
    }

    private func fetchVideo(asset: PHAsset) -> AnyPublisher<Video, UIError> {
        return Future<Video, UIError> { [weak self] resolve in
            guard let self else {
                resolve(.failure(.fetchVideos))
                return
            }
            let requestOptions = PHImageRequestOptions()

            requestOptions.isSynchronous = false
            requestOptions.deliveryMode = .highQualityFormat

            let targetSize = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
            self.manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { (image, _) in
                guard let image else {
                    resolve(.failure(.fetchVideos))
                    return
                }
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute, .second]
                formatter.zeroFormattingBehavior = [.pad]
                formatter.unitsStyle = .positional

                resolve(.success(Video(title: formatter.string(from: asset.duration), image: image)))
            }
        }
        .eraseToAnyPublisher()
    }
}

extension PhotosProvider: PhotosProviderProtocol {

    func fetchVideos() -> AnyPublisher<[Video], UIError> {
        return checkPermissionsStatus()
            .flatMap({ [weak self] in
                guard let self else {
                    return Just([PHAsset]()).setFailureType(to: UIError.self).eraseToAnyPublisher()
                }
                return self.fetchAssets()
            })
            .flatMap { assets -> AnyPublisher<Video, UIError> in
                let videoPublishers = assets.map { self.fetchVideo(asset: $0) }
                return Publishers.Sequence(sequence: videoPublishers)
                    .flatMap { $0 }
                    .eraseToAnyPublisher()
            }
            .collect()
            .eraseToAnyPublisher()
    }

}

// MARK: - Constants
private enum Constants {
    static let fetchOptionsPredicate = "mediaType == %d"
}
