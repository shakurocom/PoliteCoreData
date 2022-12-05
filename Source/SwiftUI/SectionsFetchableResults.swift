//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import Foundation
import CoreData

public struct SectionsFetchableResults<EntityType, ResultType: ManagedEntity>: FetchableResults where EntityType == ResultType.EntityType {

    public static func createFetchableResults(content: Content<FetchedResultsController<EntityType, ResultType>>) -> SectionsFetchableResults {
        return SectionsFetchableResults(content: content)
    }

    private let idString: String = NSUUID().uuidString

    private let content: Content<FetchedResultsController<EntityType, ResultType>>

    init(content: Content<FetchedResultsController<EntityType, ResultType>>) {
        self.content = content
    }
}

extension SectionsFetchableResults: RandomAccessCollection {

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return content.sections()
    }

    public subscript(position: Int) -> (name: String, items: ItemsFetchableResults<EntityType, ResultType>) {
        return (
            name: content.nameForSection(position) ?? "",
            items: ItemsFetchableResults(section: position, content: content)
        )
    }
}
