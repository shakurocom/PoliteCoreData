//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import PoliteCoreData_Framework
import SwiftUI

protocol DataStorage {
    func insertOrDeleteItems()
    func updateItems()
    func deleteItem(_ identifier: String)
    @MainActor
    func exampleFetchedResultController() -> FetchedResultsController<CDExampleEntity, ManagedExampleEntity>
    @MainActor
    func fetchableRequest() -> SimpleFetchedResultsController<CDExampleEntity, ManagedExampleEntity>
}

extension PoliteCoreStorage: DataStorage {

    static var shouldDelete = false

    func insertOrDeleteItems() {
        Task(operation: {
            try? await save({ (context) in
                for index in 0..<20 {
                    let item = ExampleEntity(identifier: "\(index)", createdAt: Date())
                    let cdItem = try self.findFirstByIdOrCreate(entityType: CDExampleEntity.self, identifier: item.identifier, inContext: context)
                    _ = cdItem.update(entity: item)
                }
                if Self.shouldDelete {
                    for _ in 0..<100 {
                        let sortDescriptor = [NSSortDescriptor(keyPath: \CDExampleEntity.createdAt, ascending: true)]
                        if let cdItem = try self.findAll(entityType: CDExampleEntity.self, context: context, sortDescriptors: sortDescriptor).first {
                            context.delete(cdItem)
                        }
                    }
                }
                Self.shouldDelete.toggle()
            })
        })
    }

    func updateItems() {
        Task(operation: {
            try await save({ (context) in
                let sortDescriptor = [NSSortDescriptor(keyPath: \CDExampleEntity.createdAt, ascending: true)]
                let cdItems = try self.findAll(entityType: CDExampleEntity.self, context: context, sortDescriptors: sortDescriptor)
                guard cdItems.count >= 6 else {
                    return
                }
                for index in [0, 1] {
                    cdItems[index].createdAt = Date().timeIntervalSince1970
                    context.delete(cdItems[index])
                }
                for index in [2, 3] {
                    cdItems[index].title = "moved \(index)"
                    cdItems[index].createdAt = Date().timeIntervalSince1970
                }
                for index in [4, 5] {
                    cdItems[index].title = "updated \(index)"
                }
                // insert
                for index in 100..<105 {
                    var item = ExampleEntity(identifier: "\(index)")
                    item.title = "inserted \(index)"
                    let cdItem = try self.findFirstByIdOrCreate(entityType: CDExampleEntity.self, identifier: item.identifier, inContext: context)
                    _ = cdItem.update(entity: item)
                }
                // update
                for index in 6...10 {
                    var item = ExampleEntity(identifier: "\(index)")
                    item.title = "moved \(index)"
                    let cdItem = try self.findFirstByIdOrCreate(entityType: CDExampleEntity.self, identifier: item.identifier, inContext: context)
                    _ = cdItem.update(entity: item)
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
            sortDescriptors: [NSSortDescriptor(key: "updatedAt", ascending: false),
                              NSSortDescriptor(key: "identifier", ascending: false)],
            configureRequest: { (request) in
                debugPrint(request)
            })
        return FetchedResultsController<CDExampleEntity, ManagedExampleEntity>(fetchedResultsController: controller)
    }

    @MainActor
    func fetchableRequest() -> SimpleFetchedResultsController<CDExampleEntity, ManagedExampleEntity> {
        let sortDescriptor = [NSSortDescriptor(keyPath: \CDExampleEntity.createdAt, ascending: true),
                              NSSortDescriptor(keyPath: \CDExampleEntity.identifier, ascending: false)]
        let controller = mainQueueFetchedResultsController(entityType: CDExampleEntity.self,
                                                           sortDescriptors: sortDescriptor,
                                                           configureRequest: nil)
        return SimpleFetchedResultsController<CDExampleEntity, ManagedExampleEntity>(fetchedResultsController: controller)
    }

}
