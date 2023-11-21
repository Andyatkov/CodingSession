//
//  PhotoItemType.swift
//  CodingSession
//
//  Created by ADyatkov on 21.11.2023.
//

import Foundation

enum PhotosSectionType: Hashable {
    case main
}

enum PhotosItemType: Hashable {
    case photo(model: PhotoCollectionViewModel)
}
