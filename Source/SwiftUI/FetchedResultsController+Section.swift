//
//
//

import Foundation

extension FetchedResultsController {

    public struct Section {

        public let title: String?

        public let items: LazyList<WrappedResult>

        public init(title: String?, items: LazyList<WrappedResult> = .empty) {
            self.title = title
            self.items = items
        }

    }

}

extension FetchedResultsController.Section: Identifiable {

    public var id: Int {
        return hashValue
    }

}

extension FetchedResultsController.Section: Equatable {

    public static func == (lhs: FetchedResultsController<EntityType, ResultType>.Section,
                           rhs: FetchedResultsController<EntityType, ResultType>.Section) -> Bool {
        return lhs.id == rhs.id
    }

}

extension FetchedResultsController.Section: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

}
