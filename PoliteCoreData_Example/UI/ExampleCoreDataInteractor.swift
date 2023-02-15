//
//
//

import SwiftUI
import PoliteCoreData_Framework

final class ExampleCoreDataInteractor: ObservableObject {

    @Published private(set) var items: LazyList<ManagedExampleEntity> = .empty

    private let dataStorage: DataStorage

    private let dataObserver: FetchedResultsController<CDExampleEntity, ManagedExampleEntity>

    init(dataStorage: DataStorage) {
        self.dataStorage = dataStorage
        self.dataObserver = dataStorage.fetchableRequest()
    }

    func setup() {
        guard !dataObserver.hasFetchedObjects else {
            return
        }

        dataObserver.didChangeContent = { [weak self] controller in
            guard let self = self else {
                return
            }
            self.items = controller.lazyItems()
        }

        try? dataObserver.performFetch()
        items = dataObserver.lazyItems()
    }

    func deleteLastItem() {
        dataStorage.deleteLastItem()
    }

    func insertLastItem() {
        dataStorage.insertLastItem()
    }

}
