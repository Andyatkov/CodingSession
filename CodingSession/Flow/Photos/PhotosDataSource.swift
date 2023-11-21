//
//  PhotosDataSource.swift
//  CodingSession
//
//  Created by ADyatkov on 21.11.2023.
//

import UIKit

final class PhotosDataSource: UICollectionViewDiffableDataSource<PhotosSectionType, PhotosItemType> {

    // MARK: - Typealias
    typealias Snapshot = NSDiffableDataSourceSnapshot<PhotosSectionType, PhotosItemType>

    init(collectionView: UICollectionView) {
        super.init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .photo(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as? PhotoCollectionViewCell
                cell?.configure(viewModel: model)
                return cell
            }
        }
    }

}

// MARK: - Constants
private enum Constants {
    static let cellIdentifier: String = "PhotoCollectionViewCell"
}

