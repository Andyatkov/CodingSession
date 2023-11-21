//
//  PhotosViewBuilder.swift
//  CodingSession
//
//  Created by ADyatkov on 21.11.2023.
//

import Combine
import UIKit

enum PhotosViewBuilder {

    // MARK: - Public methods
    static func build() -> PhotosViewController {
        // Здесь потом можно сделать DI
        let provider = PhotosProvider()
        
        let viewModel = PhotosViewModel(
            provider: provider
        )
        let viewController = PhotosViewController(viewModel: viewModel)
        return viewController
    }

}
