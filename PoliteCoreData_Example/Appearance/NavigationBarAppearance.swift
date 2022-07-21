//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import UIKit

struct NavigationBarAppearance: Appearance {
    func appearance() {
        let backgroundColor = UIColor.white
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()

            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = backgroundColor

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().isTranslucent = true
            UINavigationBar.appearance().backgroundColor = backgroundColor
        }
    }
}
