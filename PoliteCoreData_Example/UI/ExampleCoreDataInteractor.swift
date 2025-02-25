//
//
//

import SwiftUI
import PoliteCoreData_Framework

@MainActor
final class ExampleCoreDataInteractor: ObservableObject {

    private let dataStorage: DataStorage

    internal let lazyListDataSource: LazyListDataSource<CDExampleEntity, ManagedExampleEntity>

    init(dataStorage: DataStorage) {
        self.dataStorage = dataStorage
        self.lazyListDataSource = LazyListDataSource(fetchedResultsController: dataStorage.fetchableRequest())
    }

    func setup() {
        lazyListDataSource.didChange = { [weak self] in
            self?.objectWillChange.send()
        }
        try? lazyListDataSource.performFetch()
    }

    func updateItems() {
        dataStorage.updateItems()
    }

    func insertOrDeleteItems() {
        dataStorage.insertOrDeleteItems()
    }

    func deleteItem(_ identifier: String) {
        dataStorage.deleteItem(identifier)
    }

}
