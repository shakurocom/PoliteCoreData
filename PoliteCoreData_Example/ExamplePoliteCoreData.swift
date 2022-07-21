//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import Foundation
import PoliteCoreData_Framework

protocol DataStorage: AnyObject {
    func createItem(_ item: ListItem)
    func removeItem(_ item: ListItem)
    func itemsObserver() -> FetchedResultsController<CDListItem, ManagedListItem>
}

final class ExamplePoliteCoreData {

    private let storage: PoliteCoreStorage

    init(modelName: String) {
        do {
            storage = PoliteCoreStorage(configuration: .init(objectModelName: modelName, isExcludedFromBackup: false))

            try storage.setupStack(removeDBOnSetupFailed: true)
        } catch {
            fatalError("\(type(of: self)) - \(#function): \(error)")
        }
    }
}

extension ExamplePoliteCoreData: DataStorage {
    func createItem(_ item: ListItem) {
        storage.save({ context in
            let cdListItem = self.storage.findFirstByIdOrCreate(CDListItem.self, identifier: item.identifier, inContext: context)
            cdListItem.update(item: item)
        }, completion: { _ in })
    }

    func removeItem(_ item: ListItem) {
        storage.save({ context in
            if let cdColor = self.storage.findFirstById(CDListItem.self, identifier: item.identifier, inContext: context) {
                context.delete(cdColor)
            }
        }, completion: { _ in })
    }

    func itemsObserver() -> FetchedResultsController<CDListItem, ManagedListItem> {
        let sortDescriptors = [
            NSSortDescriptor(keyPath: \CDListItem.section, ascending: true),
            NSSortDescriptor(keyPath: \CDListItem.created, ascending: true)
        ]
        let fetchedController = storage.mainQueueFetchedResultsController(
            CDListItem.self,
            sortDescriptors: sortDescriptors,
            sectionNameKeyPath: #keyPath(CDListItem.section),
            configureRequest: nil
        )

        return FetchedResultsController(fetchedResultsController: fetchedController)
    }
}
