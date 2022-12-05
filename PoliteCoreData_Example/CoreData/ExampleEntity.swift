//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//
//

import CoreData
import Foundation
import PoliteCoreData_Framework

class ExampleEntity {

    let identifier: String
    let createdAt: Date
    let updatedAt: Date

    init(identifier: String = NSUUID().uuidString, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.identifier = identifier
    }

    init(entity: CDExampleEntity) {
        createdAt = Date(timeIntervalSince1970: entity.createdAt)
        updatedAt = Date(timeIntervalSince1970: entity.updatedAt)
        identifier = entity.identifier ?? UUID().uuidString
    }
}

final class ManagedExampleEntity: ExampleEntity, ManagedEntity {
    let objectID: NSManagedObjectID

    override init(entity: CDExampleEntity) {
        objectID = entity.objectID
        super.init(entity: entity)
    }
}

extension ManagedExampleEntity: Hashable {
    static func == (lhs: ManagedExampleEntity, rhs: ManagedExampleEntity) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
