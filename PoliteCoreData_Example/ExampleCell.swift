//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import UIKit

class ExampleCell: UITableViewCell {

    @IBOutlet private var titleLabel: UILabel!

    func setup(_ title: String) {
        titleLabel.text = title
    }
}
