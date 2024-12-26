//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//
//

import CoreData
import Foundation
import PoliteCoreData_Framework

struct ExampleEntity: Sendable {

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

struct ManagedExampleEntity: ManagedEntity, Sendable {

    let data: ExampleEntity
    let objectID: NSManagedObjectID

    init(entity: CDExampleEntity) {
        self.data = ExampleEntity(entity: entity)
        self.objectID = entity.objectID
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
            lhs.data.identifier == rhs.data.identifier &&
            lhs.data.createdAt.timeIntervalSince1970 == rhs.data.createdAt.timeIntervalSince1970 &&
            lhs.data.updatedAt.timeIntervalSince1970 == rhs.data.updatedAt.timeIntervalSince1970
        )
    }

}

extension ManagedExampleEntity: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(objectID)
        hasher.combine(data.identifier)
        hasher.combine(data.createdAt)
        hasher.combine(data.updatedAt)
    }

}
