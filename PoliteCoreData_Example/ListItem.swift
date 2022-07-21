//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import PoliteCoreData_Framework
import CoreData

class ListItem {
    let identifier: String
    let section: String
    let created: Date

    init(identifier: String = NSUUID().uuidString, section: String, created: Date = Date()) {
        self.identifier = identifier
        self.section = section
        self.created = created
    }

    init(entity: CDListItem) {
        self.identifier = entity.identifier
        self.section = entity.section
        self.created = entity.created
    }
}

final class ManagedListItem: ListItem, ManagedEntity {
    let objectID: NSManagedObjectID

    override init(entity: CDListItem) {
        objectID = entity.objectID
        super.init(entity: entity)
    }
}
