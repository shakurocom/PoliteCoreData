//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//
//

import CoreData
import Foundation

/// Wrapper on NSFetchedResultsController, provides easy way to observe single entity.
/// See: [FetchedResultsController](x-source-tag://FetchedResultsController) for more info
/// - Tag: SingleObjectFetchedResultController
public final class SingleObjectFetchedResultController<EntityType, ResultType: ManagedEntity> where ResultType.EntityType == EntityType {

    public var willChange: ((_ controller: SingleObjectFetchedResultController<EntityType, ResultType>) -> Void)?
    public var didChange: ((_ controller: SingleObjectFetchedResultController<EntityType, ResultType>) -> Void)?

    private(set) public var result: ResultType?
    private let fetchedResultsController: FetchedResultsController<EntityType, ResultType>
    private let resultIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    public init(fetchedResultsController: NSFetchedResultsController<EntityType>) {
        self.fetchedResultsController = FetchedResultsController<EntityType, ResultType>(fetchedResultsController: fetchedResultsController)
        setup()
    }

    public func performFetch() throws {
        try fetchedResultsController.performFetch()
        updateResult(report: false)
    }

    public func performFetch(predicate: NSPredicate) throws {
        try fetchedResultsController.performFetch(predicate: predicate)
        updateResult(report: false)
    }

    public func resultTyped<T: ManagedEntity>() -> T? {
        guard fetchedResultsController.numberOfSections() > resultIndexPath.section,
              fetchedResultsController.numberOfItemsInSection(resultIndexPath.section) > resultIndexPath.row
        else {
            return nil
        }
        return fetchedResultsController.itemTyped(indexPath: resultIndexPath)
    }

}

// MARK: - Private

private extension SingleObjectFetchedResultController {

    func setup() {
        fetchedResultsController.willChangeContent = {[weak self] (_) in
            guard let actualSelf = self else {
                return
            }
            actualSelf.willChange?(actualSelf)
        }
        fetchedResultsController.didChangeContent = {[weak self] (_) in
            guard let actualSelf = self else {
                return
            }
            actualSelf.updateResult(report: true)
        }
    }

    func updateResult(report: Bool) {
        defer {
            if report {
                didChange?(self)
            }
        }
        guard fetchedResultsController.numberOfSections() > resultIndexPath.section,
              fetchedResultsController.numberOfItemsInSection(resultIndexPath.section) > resultIndexPath.row
        else {
            result = nil
            return
        }
        result = fetchedResultsController.item(indexPath: resultIndexPath)
    }

}
