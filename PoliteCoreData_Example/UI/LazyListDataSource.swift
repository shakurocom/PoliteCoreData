//
//
//

import Foundation
import PoliteCoreData_Framework

public class LazyListDataSource<EntityType, ResultType: ManagedEntity> where ResultType.EntityType == EntityType {

    public var didChange: (() -> Void)?

    internal private(set) var items: [LazyListDataSourceItem] = []

    private let fetchedResultsController: SimpleFetchedResultsController<EntityType, ResultType>?
    private let logChanges: Bool = false

    // MARK: - Initialization

    public init(fetchedResultsController: SimpleFetchedResultsController<EntityType, ResultType>?) {
        self.fetchedResultsController = fetchedResultsController
    }

    // MARK: - Public

    public func performFetch() throws {
        try fetchedResultsController?.performFetch()
        fetchedResultsController?.didChange = { [weak self] (_, changes) in // swiftlint:disable:this closure_body_length
            guard let strongSelf = self else {
                return
            }
            var inserted: [Int] = []
            var deleted: [Int] = []
            var updated: [Int] = []
            var moved: [(fromIndex: Int, toIndex: Int)] = []
            for change in changes {
                switch change {
                case .insert(let indexPath):
                    inserted.append(indexPath.row)
                case .delete(let indexPath):
                    deleted.append(indexPath.row)
                case .move(let indexPath, let newIndexPath):
                    moved.append((fromIndex: indexPath.row, toIndex: newIndexPath.row))
                case .update(let indexPath):
                    updated.append(indexPath.row)
                case .insertSection,
                        .deleteSection:
                    fatalError("Sections are not supported")
                }
            }
            var itemsUpdated = strongSelf.items
            if strongSelf.logChanges {
                for index in updated {
                    print("Updated item at index \(index); count = \(itemsUpdated.count)")
                }
            }
            for index in inserted.sorted(by: { $0 < $1 }) {
                if strongSelf.logChanges {
                    print("Inserted item at index \(index); count = \(itemsUpdated.count)")
                }
                itemsUpdated.insert(LazyListDataSourceItem(), at: index)
            }
            for index in deleted.sorted(by: { $0 > $1 }) {
                if strongSelf.logChanges {
                    print("Deleted item at index \(index); \(itemsUpdated.count)")
                }
                itemsUpdated.remove(at: index)
            }
            for movedItem in moved {
                if strongSelf.logChanges {
                    print("Moved item from index \(movedItem.fromIndex) to index \(movedItem.toIndex); count = \(itemsUpdated.count) ")
                }
                itemsUpdated.move(fromOffsets: IndexSet(integer: movedItem.fromIndex), toOffset: movedItem.toIndex)
            }
            if !changes.isEmpty {
                strongSelf.items = itemsUpdated
                strongSelf.didChange?()
                if strongSelf.logChanges {
                    print("Updated items; count = \(strongSelf.items.count)")
                }
            }
        }
        let numberOfItems = fetchedResultsController?.numberOfItemsInSection(0) ?? 0
        self.items = (0..<numberOfItems).map({ _ in LazyListDataSourceItem() })
        didChange?()
    }

    public func numberOfItemsInSection(_ index: Int) -> Int {
        return fetchedResultsController?.numberOfItemsInSection(index) ?? 0
    }

    public func dataItem(item: LazyListDataSourceItem) -> ResultType? {
        guard let index = index(item: item) else {
            return nil
        }
        return fetchedResultsController?.item(indexPath: IndexPath(row: index, section: 0))
    }

    public func index(item: LazyListDataSourceItem) -> Int? {
        return items.firstIndex(of: item)
    }

}

// MARK: - LazyListDataSourceItem

public struct LazyListDataSourceItem: Identifiable, Equatable {

    public let id: String

    internal init() {
        self.id = UUID().uuidString
    }

}
