//
//  SceneDelegate.swift
//  CodingSession
//
//  Created by Pavel Ilin on 01.11.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties
    var window: UIWindow?

    // MARK: - Private methods
    private func setupMainWindow(for scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene), window == nil else {
            return
        }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = PhotosViewBuilder.build()
        window?.makeKeyAndVisible()
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        setupMainWindow(for: scene)
    }

}

