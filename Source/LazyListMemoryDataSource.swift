//
//
//

import Foundation

public class LazyListMemoryDataSource<ResultType> {

    public var didChange: (() -> Void)?

    internal private(set) var items: [LazyListDataSourceItem] = []

    private var dataItems: [ResultType] = []

    // MARK: - Initialization

    public init(dataItems: [ResultType]) {
        self.dataItems = dataItems
        self.items = (0..<dataItems.count).map({ _ in LazyListDataSourceItem() })
    }

    // MARK: - Public

    public func dataItem(item: LazyListDataSourceItem) -> ResultType? {
        guard let index = index(item: item),
              index >= 0 && index < dataItems.count
        else {
            return nil
        }
        return dataItems[index]
    }

    public func index(item: LazyListDataSourceItem) -> Int? {
        return items.firstIndex(of: item)
    }

    public func appendDataItems(_ newDataItems: [ResultType]) {
        dataItems.append(contentsOf: dataItems)
        for _ in 0..<newDataItems.count {
            items.append(LazyListDataSourceItem())
        }
        didChange?()
    }

}
