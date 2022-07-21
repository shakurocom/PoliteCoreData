//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import Foundation

protocol Appearance {
    func appearance()
}

enum AppAppearance {
    static func appearance() {
        let appearances: [Appearance] = [
            NavigationBarAppearance()
        ]
        appearances.forEach({ $0.appearance() })
    }
}
