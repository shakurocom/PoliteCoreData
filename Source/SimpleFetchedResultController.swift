//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//
//

import CoreData
import Foundation

/// Wrapper on NSFetchedResultsController, provides easy way to observe single entity.
/// See: [FetchedResultsController](x-source-tag://FetchedResultsController) for more info
/// - Tag: SimpleFetchedResultController
public final class SimpleFetchedResultController<EntityType, ResultType: ManagedEntity> where ResultType.EntityType == EntityType {

    public var willChange: ((_ controller: SimpleFetchedResultController<EntityType, ResultType>) -> Void)?
    public var didChange: ((_ controller: SimpleFetchedResultController<EntityType, ResultType>, _ changes: [FetchedResultsControllerChange]) -> Void)?

    private let fetchedResultsController: FetchedResultsController<EntityType, ResultType>
    private var combinedChanges: [FetchedResultsControllerChange] = []

    public init(fetchedResultsController: NSFetchedResultsController<EntityType>) {
        self.fetchedResultsController = FetchedResultsController<EntityType, ResultType>(fetchedResultsController: fetchedResultsController)
        self.fetchedResultsController.willChangeContent = { [weak self] (_) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.willChange?(strongSelf)
        }
        self.fetchedResultsController.didChangeEntity = { [weak self] (_, change) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.combinedChanges.append(change)
        }
        self.fetchedResultsController.didChangeContent = { [weak self] (_) -> Void in
            guard let strongSelf = self else { return }
            let localCombinedChanges = strongSelf.combinedChanges
            strongSelf.combinedChanges = []
            strongSelf.didChange?(strongSelf, localCombinedChanges)
        }
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func performFetch() throws {
        try fetchedResultsController.performFetch()
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func performFetch(predicate: NSPredicate) throws {
        try fetchedResultsController.performFetch(predicate: predicate)
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func setSortDescriptors(_ sortDescriptors: [NSSortDescriptor], shouldPerformFetch: Bool) {
        fetchedResultsController.setSortDescriptors(sortDescriptors, shouldPerformFetch: shouldPerformFetch)
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func totalNumberOfItems() -> Int {
        return fetchedResultsController.totalNumberOfItems()
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func numberOfItemsInSection(_ index: Int) -> Int {
        return fetchedResultsController.numberOfItemsInSection(index)
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func sectionName(_ index: Int) -> String? {
        return fetchedResultsController.sectionName(index)
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func numberOfSections() -> Int {
        return fetchedResultsController.numberOfSections()
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func item(indexPath: IndexPath) -> ResultType {
        return fetchedResultsController.item(indexPath: indexPath)
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func itemTyped<T: ManagedEntity>(indexPath: IndexPath) -> T? {
        fetchedResultsController.itemTyped(indexPath: indexPath)
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func indexPath(entity: ResultType) -> IndexPath? {
        fetchedResultsController.indexPath(entity: entity)
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func item(url: URL) -> ResultType? {
        fetchedResultsController.item(url: url)
    }

    /// See [FetchedResultsController](x-source-tag://FetchedResultsController)
    public func forEach(inSection section: Int, body: (IndexPath, ResultType) -> Bool) {
        fetchedResultsController.forEach(inSection: section, body: body)
    }

}
