//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import Foundation

public protocol FetchableResults {

    associatedtype EntityType

    associatedtype ResultType: ManagedEntity where EntityType == ResultType.EntityType

    static func createFetchableResults(content: Content<FetchedResultsController<EntityType, ResultType>>) -> Self
}
