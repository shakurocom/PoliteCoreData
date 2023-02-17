//
//
//

import Foundation

extension FetchedResultsController {

    public struct Section: Identifiable {

        public let id: UUID = UUID()

        public let title: String?

        public let items: LazyList<ResultType>

        public init?(title: String?, items: LazyList<ResultType>?) {
            guard let items = items else {
                return nil
            }

            self.title = title
            self.items = items
        }

    }

    public var hasFetchedObjects: Bool {
        return fetchedResultsController.fetchedObjects != nil
    }

    public func lazySections() -> LazyList<Section> {
        return LazyList(capacity: numberOfSections()) { [weak self] section in
            return Section(title: self?.sectionName(section),
                           items: self?.lazyItems(in: section))
        }
    }

    public func lazyItems(in section: Int = 0) -> LazyList<ResultType> {
        return LazyList(capacity: numberOfItemsInSection(section)) { [weak self] item in
            return self?.item(indexPath: IndexPath(item: item, section: section))
        }
    }

}

extension FetchedResultsController.Section: Equatable where ResultType: Equatable {

    public static func == (lhs: FetchedResultsController<EntityType, ResultType>.Section, rhs: FetchedResultsController<EntityType, ResultType>.Section) -> Bool {
        return lhs.title == rhs.title && lhs.items == rhs.items
    }

}
