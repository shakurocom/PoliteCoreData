//
//
//

import SwiftUI
import UIKit
import Shakuro_CommonTypes

class HostingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

private extension HostingViewController {
    @IBAction private func uiKitTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller: ExampleCoreDataViewController = storyboard.instantiateViewController(withIdentifier: "ExampleCoreDataViewController")

        navigationController?.setViewControllers([controller], animated: false)
    }

    @IBAction private func swiftUITapped() {
        let swiftUIViewController = UIHostingController(rootView: SwiftUIView())
        navigationController?.setViewControllers([swiftUIViewController], animated: false)
    }
}
