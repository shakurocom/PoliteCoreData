//
//
//

import SwiftUI
import UIKit
import PoliteCoreData_Framework
import Shakuro_CommonTypes

final class HostingViewController: UIViewController {

    private var storage: PoliteCoreStorage = {
        do {
            let storage = PoliteCoreStorage(configuration: PoliteCoreStorage.Configuration(objectModelName: "CoreDataExample", isExcludedFromBackup: true))
            try storage.setupStack(removeDBOnSetupFailed: true)
            return storage
        } catch let error {
            fatalError("\(error)")
        }
    }()

}

private extension HostingViewController {

    @IBAction private func uiKitTapped() {
        navigationController?.setViewControllers([ExampleCoreDataViewController.instantiate(storage)], animated: false)
    }

    @IBAction private func swiftUITapped() {
        let swiftUIViewController = UIHostingController(rootView: SwiftUIView(storage: storage))
        navigationController?.setViewControllers([swiftUIViewController], animated: false)
    }

}
