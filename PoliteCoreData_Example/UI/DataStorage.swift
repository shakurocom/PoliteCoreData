//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import PoliteCoreData_Framework
import SwiftUI

protocol DataStorage {
    func insertLastItem()
    func deleteLastItem()
    func deleteItem(_ identifier: String)
    @MainActor
    func exampleFetchedResultController() -> FetchedResultsController<CDExampleEntity, ManagedExampleEntity>
    @MainActor
    func fetchableRequest() -> FetchedResultsController<CDExampleEntity, ManagedExampleEntity>
}

extension PoliteCoreStorage: DataStorage {

    func insertLastItem() {
        Task(operation: {
            let item = ExampleEntity()
            try? await save({ (context) in
                let cdItem = try self.findFirstByIdOrCreate(entityType: CDExampleEntity.self, identifier: item.identifier, inContext: context)
                _ = cdItem.update(entity: item)
            })
        })
    }

    func deleteLastItem() {
        Task(operation: {
            try await save({ (context) in
                let sortDescriptor = [NSSortDescriptor(keyPath: \CDExampleEntity.createdAt, ascending: true)]
                if let cdItem = try self.findAll(entityType: CDExampleEntity.self, context: context, sortDescriptors: sortDescriptor).last {
                    context.delete(cdItem)
                }
            })
        })
    }

    func deleteItem(_ identifier: String) {
        Task(operation: {
            try await save({ (context) in
                if let cdItem = try self.findFirstById(entityType: CDExampleEntity.self, identifier: identifier, inContext: context) {
                    context.delete(cdItem)
                }
            })
        })
    }

    @MainActor
    func exampleFetchedResultController() -> FetchedResultsController<CDExampleEntity, ManagedExampleEntity> {
        let controller = mainQueueFetchedResultsController(
            entityType: CDExampleEntity.self,
            sortDescriptors: [NSSortDescriptor(key: "updatedAt", ascending: false)],
            configureRequest: { (request) in
                debugPrint(request)
            })
        return FetchedResultsController<CDExampleEntity, ManagedExampleEntity>(fetchedResultsController: controller)
    }

    @MainActor
    func fetchableRequest() -> FetchedResultsController<CDExampleEntity, ManagedExampleEntity> {
        let sortDescriptor = [NSSortDescriptor(keyPath: \CDExampleEntity.createdAt, ascending: true)]
        let controller = mainQueueFetchedResultsController(entityType: CDExampleEntity.self,
                                                           sortDescriptors: sortDescriptor,
                                                           configureRequest: nil)

        return FetchedResultsController<CDExampleEntity, ManagedExampleEntity>(fetchedResultsController: controller)
    }

}
