//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import PoliteCoreData_Framework
import SwiftUI

protocol DataStorage {
    func insertExampleItem(_ item: ExampleEntity)
    func deleteExampleItem(_ identifier: String)
    func exampleFetchedResultController() -> FetchedResultsController<CDExampleEntity, ManagedExampleEntity>

    func fetchableRequest() -> FetchableRequest<ItemsFetchableResults<CDExampleEntity, ManagedExampleEntity>>
}

extension PoliteCoreStorage: DataStorage {
    func insertExampleItem(_ item: ExampleEntity) {
        save({ (context) in
            let cdItem = self.findFirstByIdOrCreate(entityType: CDExampleEntity.self, identifier: item.identifier, inContext: context)
            _ = cdItem.update(entity: item)
        }, completion: { (error) in
            if let actualError = error {
                assertionFailure("\(actualError)")
            }
        })
    }

    func deleteExampleItem(_ identifier: String) {
        save({ (context) in
            if let cdItem = self.findFirstById(entityType: CDExampleEntity.self, identifier: identifier, inContext: context) {
                context.delete(cdItem)
            }
        }, completion: { (error) in
            if let actualError = error {
                assertionFailure("\(actualError)")
            }
        })
    }

    func exampleFetchedResultController() -> FetchedResultsController<CDExampleEntity, ManagedExampleEntity> {
        let controller = mainQueueFetchedResultsController(
            entityType: CDExampleEntity.self,
            sortDescriptors: [NSSortDescriptor(key: "updatedAt", ascending: false)],
            configureRequest: { (request) in
                debugPrint(request)
        })
        return FetchedResultsController<CDExampleEntity, ManagedExampleEntity>(fetchedResultsController: controller)
    }

    func fetchableRequest() -> FetchableRequest<ItemsFetchableResults<CDExampleEntity, ManagedExampleEntity>> {
        let sortDescriptor = NSSortDescriptor(keyPath: \CDExampleEntity.createdAt, ascending: true)
        let controller = mainQueueFetchedResultsController(
            entityType: CDExampleEntity.self,
            sortDescriptors: [sortDescriptor],
            // sectionNameKeyPath: #keyPath(CDExampleEntity.identifier),
            configureRequest: nil)

        return FetchableRequest(fetchedResultsController: controller, animation: .default)
    }
}
