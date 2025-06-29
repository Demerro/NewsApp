//
//  SceneDelegate.swift
//  NewsApp
//
//  Created by Nikita Prokhorchuk on 6.02.23.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var dependencyContainer: AppDependencyContainer?
    
    var coordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let window = UIWindow(windowScene: scene as! UIWindowScene)
        let dependencyContainer = AppDependencyContainer()
        let coordinator = dependencyContainer.makeCoordinator()
        window.rootViewController = coordinator.rootViewController
        window.makeKeyAndVisible()
        self.window = window
        self.dependencyContainer = dependencyContainer
        self.coordinator = coordinator
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        dependencyContainer?.articlesStorageClient.saveArticlesSubject.send(Void())
    }
}
