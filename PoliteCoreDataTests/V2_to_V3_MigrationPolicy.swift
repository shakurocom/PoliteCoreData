//
//  V1_to_V2_MigrationPolicy.swift
//  iOSToolboxTests
//
//  Created by Vlad on 27.06.2022.
//  Copyright © 2022 Shakuro. All rights reserved.
//

import CoreData

// swiftlint:disable type_name
@objc(V2_to_V3_MigrationPolicy)
class V2_to_V3_MigrationPolicy: NSEntityMigrationPolicy {

    // FUNCTION($entityPolicy, "changeIdentifierType:" , $source.identifier)
    func changeIdentifierType(identifier: Int64) -> String {
        return "\(identifier)"
    }
}
