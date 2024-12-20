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
        let item = ExampleEntity()
        save({ (context) in
            let cdItem = self.findFirstByIdOrCreate(entityType: CDExampleEntity.self, identifier: item.identifier, inContext: context)
            _ = cdItem.update(entity: item)
        }, completion: { _ in })
    }

    func deleteLastItem() {
        save({ (context) in
            let sortDescriptor = [NSSortDescriptor(keyPath: \CDExampleEntity.createdAt, ascending: true)]
            if let cdItem = self.findAll(entityType: CDExampleEntity.self, context: context, sortDescriptors: sortDescriptor).last {
                context.delete(cdItem)
            }
        }, completion: { _ in })
    }

    func deleteItem(_ identifier: String) {
        save({ (context) in
            if let cdItem = self.findFirstById(entityType: CDExampleEntity.self, identifier: identifier, inContext: context) {
                context.delete(cdItem)
            }
        }, completion: { _ in })
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
