//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import SwiftUI
import CoreData

@propertyWrapper
public struct FetchableRequest<RequestResults: FetchableResults>: DynamicProperty {

    @State public private(set) var wrappedValue: RequestResults

    private let fetchedController: FetchedResultsController<RequestResults.EntityType, RequestResults.ResultType>

    private let animation: Animation?

    private var hasFetchedObjects: Bool {
        return fetchedController.fetchedResultsController.fetchedObjects != nil
    }

    public init(fetchedResultsController: NSFetchedResultsController<RequestResults.EntityType>, animation: Animation? = nil) {
        let controller: FetchedResultsController<RequestResults.EntityType, RequestResults.ResultType> = FetchedResultsController(fetchedResultsController: fetchedResultsController)

        self.fetchedController = controller
        self.animation = animation

        _wrappedValue = State(initialValue: RequestResults.self.createFetchableResults(content: Content(collection: controller)))
    }

    public mutating func update() {
        _wrappedValue.update()
        guard !hasFetchedObjects else {
            return
        }

        let binding = $wrappedValue
        let animation = animation

        fetchedController.didChangeContent = { controller in
            withAnimation(animation) {
                binding.wrappedValue = RequestResults.self.createFetchableResults(content: Content(collection: controller))
            }
        }

        try? fetchedController.performFetch()
    }
}
