import UIKit
import SwiftUI
import StoreKit

final class RootViewController: UIViewController {

    private let spinner = UIActivityIndicatorView(style: .large)
    private var didStart = false

    override func viewDidLoad() {
        super.viewDidLoad()
        OrientationManager.shared.lockPortrait()
        view.backgroundColor = .black
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        spinner.startAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didStart else { return }
        didStart = true
        beginResolution()
    }

    override var prefersStatusBarHidden: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OrientationManager.shared.mask
    }

    private func beginResolution() {
        let hadSessionAtLaunch = TokenStorage.shared.hasSession
        Task { @MainActor in
            let resolution = await ConfigService.shared.resolve()
            switch resolution {
            case let .bridge(_, destination):
                self.presentBridge(destination: destination, requestReview: hadSessionAtLaunch)
            case .application:
                self.presentApplication()
            }
        }
    }

    private func presentBridge(destination: String, requestReview: Bool) {
        let windowScene = view.window?.windowScene
        let controller = BridgeViewController(destination: destination)
        swapRoot(with: controller)
        if requestReview && !TokenStorage.shared.didRequestReview {
            TokenStorage.shared.didRequestReview = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if let scene = windowScene ?? self.activeWindowScene() {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }

    private func activeWindowScene() -> UIWindowScene? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    }

    private func presentApplication() {
        OrientationManager.shared.lockPortrait()
        let host = PortraitHostingController(rootView: MenuRootView())
        swapRoot(with: host)
    }

    private func swapRoot(with controller: UIViewController) {
        guard let window = view.window ?? UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.keyWindow else {
            return
        }
        window.rootViewController = controller
        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: {})
    }
}
