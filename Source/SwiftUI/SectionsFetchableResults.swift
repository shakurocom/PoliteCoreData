//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import Foundation
import CoreData

public struct SectionsFetchableResults<EntityType, ResultType: ManagedEntity>: FetchableResults where EntityType == ResultType.EntityType {

    public static func createFetchableResults(content: FetchedResultsController<EntityType, ResultType>) -> SectionsFetchableResults {
        return SectionsFetchableResults(content: content)
    }

    public var stateFlag: Bool = false

    private let content: FetchedResultsController<EntityType, ResultType>

    public init(content: FetchedResultsController<EntityType, ResultType>) {
        self.content = content
    }
}

extension SectionsFetchableResults: RandomAccessCollection {

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return content.numberOfSections()
    }

    public subscript(position: Int) -> (name: String, items: ItemsFetchableResults<EntityType, ResultType>) {
        return (
            name: content.sectionName(position) ?? "",
            items: ItemsFetchableResults(section: position, content: content)
        )
    }
}
