import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let newWindow = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        let appDIContainer = AppDIContainter()
        let appFlowCoordinator = AppFlowCoordinator(diContainer: appDIContainer, navigationController: navigationController)
        appFlowCoordinator.start()
        newWindow.rootViewController = navigationController
        newWindow.makeKeyAndVisible()
        self.window = newWindow
    }
}

