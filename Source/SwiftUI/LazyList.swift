//
//
//

import Foundation

public struct LazyList<Element> {

    public typealias Access = (Int) throws -> Element?

    public enum Error: LocalizedError {

        case elementIsNil(index: Int)

        var localizedDescription: String {
            switch self {
            case let .elementIsNil(index):
                return "Element at index \(index) is nil"
            }
        }

    }

    public static var empty: Self {
        return LazyList { index in
            throw Error.elementIsNil(index: index)
        }
    }

    private let capacity: Int

    private let access: Access

    public init(capacity: Int = 0, _ access: @escaping Access) {
        self.capacity = capacity
        self.access = access
    }

}

private extension LazyList {

    private func element(at index: Int) throws -> Element {
        guard let element = try access(index) else {
            throw Error.elementIsNil(index: index)
        }
        return element
    }

}

extension LazyList: Sequence {

    public struct Iterator: IteratorProtocol {

        private var index = -1

        private var list: LazyList<Element>

        public init(list: LazyList<Element>) {
            self.list = list
        }

        mutating public func next() -> Element? {
            index += 1
            guard index < list.capacity else {
                return nil
            }
            do {
                return try list.element(at: index)
            } catch _ {
                return nil
            }
        }

    }

    public var underestimatedCount: Int {
        return capacity
    }

    public func makeIterator() -> Iterator {
        return Iterator(list: self)
    }

}

extension LazyList: RandomAccessCollection {

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return capacity
    }

    public subscript(index: Int) -> Iterator.Element {
        do {
            return try element(at: index)
        } catch let error {
            fatalError("\(error)")
        }
    }

    public func index(after index: Int) -> Int {
        return index + 1
    }

    public func index(before index: Int) -> Int {
        return index - 1
    }

}

extension LazyList: Equatable where Element: Equatable {

    public static func == (lhs: LazyList<Element>, rhs: LazyList<Element>) -> Bool {
        guard lhs.capacity == rhs.capacity else {
            return false
        }
        return zip(lhs, rhs).first(where: { $0 != $1 }) == nil
    }

}
