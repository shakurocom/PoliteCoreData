//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import Foundation
import CoreData

public struct ItemsFetchableResults<EntityType, ResultType: ManagedEntity>: FetchableResults where EntityType == ResultType.EntityType {

    public var stateFlag: Bool = false

    private let section: Int

    private let content: FetchedResultsController<EntityType, ResultType>

    public init(content: FetchedResultsController<EntityType, ResultType>) {
        self.section = 0
        self.content = content
    }

    init(section: Int = 0, content: FetchedResultsController<EntityType, ResultType>) {
        self.section = section
        self.content = content
    }

}

extension ItemsFetchableResults: RandomAccessCollection {

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return content.numberOfItemsInSection(section)
    }

    public subscript(position: Int) -> ResultType {
        return content.item(indexPath: IndexPath(item: position, section: section))
    }

}
