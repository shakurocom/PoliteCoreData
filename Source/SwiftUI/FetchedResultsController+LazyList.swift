//
//
//

import Foundation

extension FetchedResultsController {

    public var hasFetchedObjects: Bool {
        return fetchedResultsController.fetchedObjects != nil
    }

    public func lazySections() -> LazyList<Section> {
        return LazyList(capacity: numberOfSections(), { [weak self] sectionIndex in
            guard let strongSelf = self,
                  sectionIndex < strongSelf.numberOfSections(),
                  sectionIndex >= 0
            else {
                return Section()
            }

            let title = strongSelf.sectionName(sectionIndex)
            let items = strongSelf.lazyItems(sectionIndex: sectionIndex)

            return Section(title: title, items: items)
        })
    }

    public func lazyItems(sectionIndex: Int = 0) -> LazyList<WrappedResult> {
        return LazyList(capacity: numberOfItemsInSection(sectionIndex), { [weak self] itemIndex in
            guard let strongSelf = self,
                  sectionIndex < strongSelf.numberOfSections(),
                  sectionIndex >= 0,
                  itemIndex < strongSelf.numberOfItemsInSection(sectionIndex),
                  itemIndex >= 0
            else {
                return .empty(section: sectionIndex, row: itemIndex)
            }
            let indexPath = IndexPath(row: itemIndex, section: sectionIndex)
            return .value(element: strongSelf.item(indexPath: indexPath))
        })
    }

}
