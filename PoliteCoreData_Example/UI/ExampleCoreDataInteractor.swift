//
//
//

import SwiftUI
import PoliteCoreData_Framework

@MainActor
final class ExampleCoreDataInteractor: ObservableObject {

    private let dataStorage: DataStorage

    private let lazyListDataSource: LazyListDatabaseDataSource<CDExampleEntity, ManagedExampleEntity>

    init(dataStorage: DataStorage) {
        self.dataStorage = dataStorage
        self.lazyListDataSource = LazyListDatabaseDataSource(fetchedResultsController: dataStorage.fetchableRequest())
    }

    func setup() {
        lazyListDataSource.didChange = { [weak self] in
            self?.objectWillChange.send()
        }
        try? lazyListDataSource.performFetch()
    }

    internal func lazyListDataSourceItems() -> [LazyListDataSourceItem] {
        return lazyListDataSource.items
    }

    internal func dataItem(item: LazyListDataSourceItem) -> ManagedExampleEntity? {
        return lazyListDataSource.dataItem(item: item)
    }

    internal func dataItem(index: Int) -> ManagedExampleEntity? {
        guard index >= 0 && index < lazyListDataSource.items.count else {
            return nil
        }
        return lazyListDataSource.dataItem(item: lazyListDataSource.items[index])
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
