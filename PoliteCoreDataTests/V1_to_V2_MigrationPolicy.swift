//
//  V1_to_V2_MigrationPolicy.swift
//  iOSToolboxTests
//
//  Created by Vlad on 27.06.2022.
//  Copyright © 2022 Shakuro. All rights reserved.
//

import CoreData

// swiftlint:disable type_name
@objc(V1_to_V2_MigrationPolicy)
class V1_to_V2_MigrationPolicy: NSEntityMigrationPolicy {

    // FUNCTION($entityPolicy, "changeIdentifierType:" , $source.identifier)
    func changeIdentifierType(identifier: String) -> Int {
        return Int(identifier) ?? 0
    }
}
// swiftlint:enable type_name
