//
//  PhotosProviderProtocol.swift
//  CodingSession
//
//  Created by ADyatkov on 21.11.2023.
//

import Combine
import Foundation

protocol PhotosProviderProtocol {

    /// Запрос списка видео пользователя
    func fetchVideos() -> AnyPublisher<[Video], UIError>

}
