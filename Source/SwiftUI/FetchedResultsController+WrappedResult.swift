//
//
//

import Foundation

extension FetchedResultsController {

    public enum WrappedResult {

        case value(element: ResultType)

        case empty(section: Int, row: Int)

    }

}

extension FetchedResultsController.WrappedResult: Identifiable {

    public var id: Int {
        return hashValue
    }

}

extension FetchedResultsController.WrappedResult: Equatable {

    public static func == (lhs: FetchedResultsController<EntityType, ResultType>.WrappedResult,
                           rhs: FetchedResultsController<EntityType, ResultType>.WrappedResult) -> Bool {
        return lhs.id == rhs.id
    }

}

extension FetchedResultsController.WrappedResult: Hashable {

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .value(let element):
            hasher.combine(element.objectID)
        case .empty(let section, let row):
            hasher.combine(section)
            hasher.combine(row)
        }
    }

}
