//
// Copyright (c) 2022 Shakuro (https://shakuro.com/)
//
//

import CoreData
import PoliteCoreData_Framework

extension CDListItem {
    @discardableResult
    func update(item: ListItem) -> Bool {
        var changed: Bool = false
        guard isInserted || (item.identifier == identifier) else {
            return changed
        }

        changed = apply(path: \.identifier, value: item.identifier) || changed
        changed = apply(path: \.section, value: item.section) || changed
        changed = apply(path: \.created, value: item.created) || changed

        return changed
    }

    func apply<Value>(path: ReferenceWritableKeyPath<CDListItem, Value?>, value: Value?) -> Bool where Value: Equatable {
        return NSManagedObject.applyValue(to: self, path: path, value: value)
    }

    func apply<Value>(path: ReferenceWritableKeyPath<CDListItem, Value>, value: Value) -> Bool where Value: Equatable {
        return NSManagedObject.applyValue(to: self, path: path, value: value)
    }
}
