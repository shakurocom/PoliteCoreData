//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import Foundation

public protocol ContentCollection {

    associatedtype ResultType

    func sections() -> Int
    func nameForSection(_ section: Int) -> String?
    func itemsInSection(_ section: Int) -> Int

    subscript(indexPath: IndexPath) -> ResultType { get }
}

extension FetchedResultsController: ContentCollection {

    public func sections() -> Int {
        return numberOfSections()
    }

    public func nameForSection(_ section: Int) -> String? {
        return sectionName(section)
    }

    public func itemsInSection(_ section: Int) -> Int {
        return numberOfItemsInSection(section)
    }

    public subscript(indexPath: IndexPath) -> ResultType {
        return item(indexPath: indexPath)
    }
}

public struct Content<Collection: ContentCollection> {

    private let collection: Collection

    public init(collection: Collection) {
        self.collection = collection
    }

    public func sections() -> Int {
        return collection.sections()
    }

    public func nameForSection(_ section: Int) -> String? {
        return collection.nameForSection(section)
    }

    public func itemsInSection(_ section: Int) -> Int {
        return collection.itemsInSection(section)
    }

    public subscript(indexPath: IndexPath) -> Collection.ResultType {
        return collection[indexPath]
    }
}
