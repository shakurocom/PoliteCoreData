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
        identifier = entity.identifier
    }
}

final class ManagedExampleEntity: ExampleEntity, ManagedEntity {

    let objectID: NSManagedObjectID

    override init(entity: CDExampleEntity) {
        objectID = entity.objectID
        super.init(entity: entity)
    }
}

extension ManagedExampleEntity: Identifiable {

    var id: String {
        return objectID.uriRepresentation().absoluteString
    }

}

extension ManagedExampleEntity: Equatable {

    static func == (lhs: ManagedExampleEntity, rhs: ManagedExampleEntity) -> Bool {
        return (
            lhs.objectID == rhs.objectID &&
            lhs.identifier == rhs.identifier &&
            lhs.createdAt.timeIntervalSince1970 == rhs.createdAt.timeIntervalSince1970 &&
            lhs.updatedAt.timeIntervalSince1970 == rhs.updatedAt.timeIntervalSince1970
        )
    }

}

extension ManagedExampleEntity: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
        hasher.combine(identifier)
        hasher.combine(createdAt)
        hasher.combine(updatedAt)
    }

}
