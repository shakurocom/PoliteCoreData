//
//
//

@testable import PoliteCoreData_Framework
import CoreData
import XCTest

final class PoliteCoreDataTests: XCTestCase {

    private let namesConfig = PoliteCoreStorage.Configuration(objectModelName: "MigrationTestNames", isExcludedFromBackup: true)
    private let idsConfig = PoliteCoreStorage.Configuration(objectModelName: "MigrationTestIds", isExcludedFromBackup: true)

    // swiftlint:disable identifier_name
    private var V0_V1Success: Bool = false
    private var V1_V2Success: Bool = false
    private var V2_V3Success: Bool = false

    override func setUp() {
        if FileManager.default.fileExists(atPath: namesConfig.sqliteStoreDirectoryURL.path) {
            _ = try? FileManager.default.removeItem(at: namesConfig.sqliteStoreDirectoryURL)
        }
        _ = try? FileManager.default.createDirectory(at: namesConfig.sqliteStoreDirectoryURL,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        if FileManager.default.fileExists(atPath: idsConfig.sqliteStoreDirectoryURL.path) {
            _ = try? FileManager.default.removeItem(at: idsConfig.sqliteStoreDirectoryURL)
        }
        _ = try? FileManager.default.createDirectory(at: idsConfig.sqliteStoreDirectoryURL,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        V0_V1Success = false
        V1_V2Success = false
        V2_V3Success = false
    }

    // improve core data test inside library: implement test with testing actual steps and make several moms (valid and broken) and check if migrations actually started

    func testMigrationNamesList () {
        let configuration = namesConfig
        let storage = PoliteCoreStorage(configuration: configuration)
        do {
            let startModel = try PoliteCoreStorage.MigrationModelVersion(configuration.objectModelURL.appendingPathComponent("MigrationTestNames.mom"))
            _ = try setupTemporaryStack(managedObjectModel: startModel.model,
                                        sqliteFileURL: configuration.sqliteStoreURL)
            let list = PoliteCoreStorage.MigrationOrder.modelNameList([
                "MigrationTestNames",
                "MigrationTestNames_1",
                "MigrationTestNames_2",
                "MigrationTestNames_3"
            ])
            try storage.migrate(migrationOrder: list) { fromVersion, toVersion in
                switch (fromVersion.modelName, toVersion.modelName) {
                case ("MigrationTestNames", "MigrationTestNames_1"):
                    self.V0_V1Success = true
                case ("MigrationTestNames_1", "MigrationTestNames_2"):
                    self.V1_V2Success = true
                case ("MigrationTestNames_2", "MigrationTestNames_3"):
                    self.V2_V3Success = true
                default:
                    XCTFail("Undefined migration from \(fromVersion.modelName) to \(toVersion.modelName)")
                }
            }
            try storage.setupStack(removeDBOnSetupFailed: false)
        } catch let error {
            XCTFail("Migration failed: \(error)")
        }
        XCTAssertTrue(V0_V1Success && V1_V2Success && V2_V3Success, "Migration failed")
    }

    func testMigrationIds() {
        let configuration = idsConfig
        let storage = PoliteCoreStorage(configuration: configuration)
        do {
            let startModel = try PoliteCoreStorage.MigrationModelVersion(configuration.objectModelURL.appendingPathComponent("MigrationTestIds.mom"))
            _ = try setupTemporaryStack(managedObjectModel: startModel.model,
                                        sqliteFileURL: configuration.sqliteStoreURL)
            try storage.migrate(migrationOrder: .modelIdentifiers) { fromVersion, toVersion in
                switch (fromVersion.versionIdentifier, toVersion.versionIdentifier) {
                case ("version1", "version2"):
                    self.V0_V1Success = true
                case ("version2", "version3"):
                    self.V1_V2Success = true
                case ("version3", "version11"):
                    self.V2_V3Success = true
                default:
                    XCTFail("Undefined migration from \(fromVersion.modelName) to \(toVersion.modelName)")
                }
            }
            try storage.setupStack(removeDBOnSetupFailed: false)
        } catch let error {
            XCTFail("Migration failed: \(error)")
        }
        XCTAssertTrue(V0_V1Success && V1_V2Success && V2_V3Success, "Migration failed")
    }

    func testMigrationIdsList () {
        let configuration = idsConfig
        let storage = PoliteCoreStorage(configuration: configuration)
        do {
            let startModel = try PoliteCoreStorage.MigrationModelVersion(configuration.objectModelURL.appendingPathComponent("MigrationTestIds.mom"))
            _ = try setupTemporaryStack(managedObjectModel: startModel.model,
                                        sqliteFileURL: configuration.sqliteStoreURL)
            let list = PoliteCoreStorage.MigrationOrder.modelIdentifierList([
                "version1",
                "version2",
                "version3",
                "version11"
            ])
            try storage.migrate(migrationOrder: list) { fromVersion, toVersion in
                switch (fromVersion.versionIdentifier, toVersion.versionIdentifier) {
                case ("version1", "version2"):
                    self.V0_V1Success = true
                case ("version2", "version3"):
                    self.V1_V2Success = true
                case ("version3", "version11"):
                    self.V2_V3Success = true
                default:
                    XCTFail("Undefined migration from \(fromVersion.modelName) to \(toVersion.modelName)")
                }
            }
           try storage.setupStack(removeDBOnSetupFailed: false)
        } catch let error {
            XCTFail("Migration failed: \(error)")
        }
        XCTAssertTrue(V0_V1Success && V1_V2Success && V2_V3Success, "Migration failed")
    }

    private func handleMigrationToVersion2(managedObjectModel: NSManagedObjectModel, sqliteFileURL: URL) -> Error? {
        var error: Error?
        do {
            // check data that were saved in previous migration steps
            let stack = try self.setupTemporaryStack(managedObjectModel: managedObjectModel, sqliteFileURL: sqliteFileURL)
            try self.saveContextAndWait(stack.context, changesBlock: { (context) in
                let request: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "CDDanalyticsEvent")
                let events = try? context.fetch(request)
                XCTAssertTrue(events?.isEmpty == true, "Events were not removed.")
            })
            // save new data that became available after migration
            try self.saveContextAndWait(stack.context, changesBlock: { (context) in
                let basket = NSEntityDescription.insertNewObject(forEntityName: "CDScanGoBasket", into: context)
                basket.setValue(UUID(), forKey: "sessionUUID")
                var items = Set<NSManagedObject>()
                for _ in 1...10 {
                    let item = NSEntityDescription.insertNewObject(forEntityName: "CDScanGoBasketItem", into: context)
                    item.setValue(UUID(), forKey: "itemUUID")
                    items.insert(item)
                }
                basket.setValue(items, forKey: "items")
            })
            // check new data that became available after migration
            try saveContextAndWait(stack.context, changesBlock: { (context) in
                let request: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "CDScanGoBasket")
                let baskets = try? context.fetch(request)
                XCTAssertTrue(baskets?.count == 1, "Wrong baskets count.")
                let uuid = baskets?.first?.value(forKey: "sessionUUID") as? UUID
                XCTAssertTrue(uuid != nil, "Basket UUID does not exist.")
                let items = (baskets?.first?.value(forKey: "items") as? Set<NSManagedObject>) ?? []
                XCTAssertTrue(items.count == 10, "Wrong items count.")
                for item in items {
                    let uuid = item.value(forKey: "itemUUID") as? UUID
                    XCTAssertTrue(uuid != nil, "Basket item UUID does not exist.")
                }
            })
        } catch let errorActual {
            error = errorActual
        }
        return error
    }

    private func setupTemporaryStack(
        managedObjectModel: NSManagedObjectModel,
        sqliteFileURL: URL) throws -> (coordinator: NSPersistentStoreCoordinator, context: NSManagedObjectContext) {
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.mergePolicy = NSOverwriteMergePolicy
            context.undoManager = nil
            context.persistentStoreCoordinator = coordinator
            let options: [AnyHashable: Any] = [NSMigratePersistentStoresAutomaticallyOption: false,
                                                     NSInferMappingModelAutomaticallyOption: false]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sqliteFileURL, options: options)
            return (coordinator, context)
        }

    private func saveContextAndWait(_ context: NSManagedObjectContext,
                                    changesBlock: ((_ context: NSManagedObjectContext) -> Void)? = nil) throws {
        var saveError: Error?
        context.performAndWait {
            context.reset()
            changesBlock?(context)
            guard context.hasChanges else {
                return
            }
            do {
                try context.save()
                context.reset()
            } catch let error {
                saveError = error
            }
        }
        if let actualError = saveError {
            throw actualError
        }
    }

}
