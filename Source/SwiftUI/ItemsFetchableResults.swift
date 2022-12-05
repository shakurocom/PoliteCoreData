//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import Foundation
import CoreData

public struct ItemsFetchableResults<EntityType, ResultType: ManagedEntity>: FetchableResults where EntityType == ResultType.EntityType {

    public static func createFetchableResults(content: Content<FetchedResultsController<EntityType, ResultType>>) -> ItemsFetchableResults {
        return ItemsFetchableResults(content: content)
    }

    private let idString: String = NSUUID().uuidString

    private let section: Int

    private let content: Content<FetchedResultsController<EntityType, ResultType>>

    init(section: Int = 0, content: Content<FetchedResultsController<EntityType, ResultType>>) {
        self.section = section
        self.content = content
    }
}

extension ItemsFetchableResults: RandomAccessCollection {

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return content.itemsInSection(section)
    }

    public subscript(position: Int) -> ResultType {
        return content[IndexPath(item: position, section: section)]
    }
}
