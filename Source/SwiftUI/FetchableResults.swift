//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import Foundation

public protocol FetchableResults {

    associatedtype EntityType

    associatedtype ResultType: ManagedEntity where EntityType == ResultType.EntityType

    var stateFlag: Bool { get set }

    init(content: FetchedResultsController<EntityType, ResultType>)

}
