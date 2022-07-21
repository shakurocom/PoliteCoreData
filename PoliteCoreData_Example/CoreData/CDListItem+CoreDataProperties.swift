//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import Foundation
import CoreData

extension CDListItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDListItem> {
        return NSFetchRequest<CDListItem>(entityName: "CDListItem")
    }

    @NSManaged public var identifier: String
    @NSManaged public var section: String
    @NSManaged public var created: Date
}
