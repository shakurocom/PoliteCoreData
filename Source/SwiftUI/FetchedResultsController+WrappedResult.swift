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

    public var id: String {
        switch self {
        case .value(let element):
            return element.objectID.uriRepresentation().absoluteString
        case .empty(let section, let row):
            return "section_\(section)-row_\(row)"
        }
    }

}

extension FetchedResultsController.WrappedResult: Equatable where ResultType: Equatable {

    public static func == (lhs: FetchedResultsController<EntityType, ResultType>.WrappedResult,
                           rhs: FetchedResultsController<EntityType, ResultType>.WrappedResult) -> Bool {
        switch (lhs, rhs) {
        case (let .value(lhsElement), let .value(rhsElement)):
            return lhsElement == rhsElement
        case (let .empty(lhsSection, lhsRow), let .empty(rhsSection, rhsRow)):
            return lhsSection == rhsSection && lhsRow == rhsRow
        default:
            return false
        }
    }

}

extension FetchedResultsController.WrappedResult: Hashable where ResultType: Hashable {

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .value(let element):
            hasher.combine(element)
        case .empty(let section, let row):
            hasher.combine(section)
            hasher.combine(row)
        }
    }

}
