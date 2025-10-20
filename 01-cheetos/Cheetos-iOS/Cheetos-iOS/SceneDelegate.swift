//
//  SceneDelegate.swift
//  Cheetos-iOS
//
//  Created by 김민우 on 8/28/25.
//
import UIKit


private extension Bundle {
    var namespace: String {
        return object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        // Programmatic UI setup (no Main.storyboard)
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let cheetosRef = Cheetos()

        // ViewController 생성
        let viewController = CheetosController()
        viewController.view.backgroundColor = .systemBackground
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.title = "운세 메신저"
        
        window.rootViewController = navigationController
        self.window = window
        
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }


}

