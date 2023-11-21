//
//  PhotosViewModel.swift
//  CodingSession
//
//  Created by ADyatkov on 21.11.2023.
//

import Combine
import Foundation
import UIKit

final class PhotosViewModel {

    // MARK: - Properties
    @Published var snapshot = PhotosDataSource.Snapshot()
    @Published var outputEvent: PhotosOutputEvent?
    private var videos: [Video] = []
    private let provider: PhotosProviderProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init/Deinit
    init(provider: PhotosProviderProtocol) {
        self.provider = provider
    }

    // MARK: - Private Methods
    private func showVideos(_ videos: [Video]) {
        let items: [PhotosItemType] = videos.map({
            .photo(model: PhotoCollectionViewModel(title: $0.title, image: $0.image))
        })
        var snapshot = PhotosDataSource.Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        self.snapshot = snapshot
    }

    private func fetchVideos() {
        provider.fetchVideos()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] error in
                    guard let self else {
                        return
                    }
                    switch error {
                    case .failure(let error):
                        switch error {
                        case .noAccessPhoto:
                            self.outputEvent = .photoAccess
                        case .fetchVideos:
                            self.outputEvent = .fetchVideoError
                        case .unknown:
                            break
                        }
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] in
                    self?.videos = $0
                    self?.showVideos($0)
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Public Methods
    func viewDidLoad() {
        fetchVideos()
    }

}
