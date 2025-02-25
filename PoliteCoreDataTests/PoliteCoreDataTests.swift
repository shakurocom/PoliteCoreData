//
//
//

@testable import PoliteCoreData_Framework
import CoreData
import XCTest

final class PoliteCoreDataTests: XCTestCase {

    private let namesConfig = PoliteCoreStorage.Configuration(objectModelName: "MigrationTestNames", isExcludedFromBackup: true, isInMemory: false)
    private let idsConfig = PoliteCoreStorage.Configuration(objectModelName: "MigrationTestIds", isExcludedFromBackup: true, isInMemory: false)

    // swiftlint:disable identifier_name
    private var V0_V1Success: Bool = false
    private var V1_V2Success: Bool = false
    private var V2_V3Success: Bool = false
    // swiftlint:enable identifier_name

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

    @MainActor
    func testMigrationNamesList() async {
        let configuration = namesConfig
        let storage = PoliteCoreStorage(configuration: configuration)
        do {
            let bundle = Bundle(for: PoliteCoreDataTests.self)
            let startModel = try PoliteCoreStorage.MigrationModelVersion(configuration.objectModelURL.appendingPathComponent("MigrationTestNames.mom"))
            _ = try setupTemporaryStack(managedObjectModel: startModel.model,
                                        sqliteFileURL: configuration.sqliteStoreURL)
            let list = PoliteCoreStorage.MigrationOrder.modelNameList([
                PoliteCoreStorage.MigrationOrderItem(identifier: "MigrationTestNames"),
                PoliteCoreStorage.MigrationOrderItem(identifier: "MigrationTestNames_1",
                                                     customMappingModelName: "MigrationTestNames_v1_to_v2",
                                                     customMappingModelBundle: bundle),
                PoliteCoreStorage.MigrationOrderItem(identifier: "MigrationTestNames_2",
                                                     customMappingModelName: "MigrationTestNames_v2_to_v3",
                                                     customMappingModelBundle: bundle),
                PoliteCoreStorage.MigrationOrderItem(identifier: "MigrationTestNames_3")
            ])
            try await storage.migrate(migrationOrder: list) { fromVersion, toVersion in
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
            try await storage.setupStack(removeDBOnSetupFailed: false)
        } catch let error {
            XCTFail("Migration failed: \(error)")
        }
        XCTAssertTrue(V0_V1Success && V1_V2Success && V2_V3Success, "Migration failed")
    }

    @MainActor
    func testMigrationIds() async {
        let configuration = idsConfig
        let storage = PoliteCoreStorage(configuration: configuration)
        do {
            let bundle = Bundle(for: PoliteCoreDataTests.self)
            let startModel = try PoliteCoreStorage.MigrationModelVersion(configuration.objectModelURL.appendingPathComponent("MigrationTestIds.mom"))
            _ = try setupTemporaryStack(managedObjectModel: startModel.model,
                                        sqliteFileURL: configuration.sqliteStoreURL)
            try await storage.migrate(
                migrationOrder: .modelIdentifiers(items: [
                    PoliteCoreStorage.MigrationOrderItem(identifier: "version1"),
                    PoliteCoreStorage.MigrationOrderItem(identifier: "version2",
                                                         customMappingModelName: "Model_v1_to_v2_ids",
                                                         customMappingModelBundle: bundle),
                    PoliteCoreStorage.MigrationOrderItem(identifier: "version3",
                                                         customMappingModelName: "Model_v2_to_v3_ids",
                                                         customMappingModelBundle: bundle),
                    PoliteCoreStorage.MigrationOrderItem(identifier: "version11")
                ]),
                migrationStep: { fromVersion, toVersion in
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
                })
            try await storage.setupStack(removeDBOnSetupFailed: false)
        } catch let error {
            XCTFail("Migration failed: \(error)")
        }
        XCTAssertTrue(V0_V1Success && V1_V2Success && V2_V3Success, "Migration failed")
    }

    @MainActor
    func testMigrationIdsList() async {
        let configuration = idsConfig
        let storage = PoliteCoreStorage(configuration: configuration)
        do {
            let bundle = Bundle(for: PoliteCoreDataTests.self)
            let startModel = try PoliteCoreStorage.MigrationModelVersion(configuration.objectModelURL.appendingPathComponent("MigrationTestIds.mom"))
            _ = try setupTemporaryStack(managedObjectModel: startModel.model,
                                        sqliteFileURL: configuration.sqliteStoreURL)
            let list = PoliteCoreStorage.MigrationOrder.modelIdentifierList([
                PoliteCoreStorage.MigrationOrderItem(identifier: "version1"),
                PoliteCoreStorage.MigrationOrderItem(identifier: "version2",
                                                     customMappingModelName: "Model_v1_to_v2_ids",
                                                     customMappingModelBundle: bundle),
                PoliteCoreStorage.MigrationOrderItem(identifier: "version3",
                                                     customMappingModelName: "Model_v2_to_v3_ids",
                                                     customMappingModelBundle: bundle),
                PoliteCoreStorage.MigrationOrderItem(identifier: "version11")
            ])
            try await storage.migrate(migrationOrder: list) { fromVersion, toVersion in
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
           try await storage.setupStack(removeDBOnSetupFailed: false)
        } catch let error {
            XCTFail("Migration failed: \(error)")
        }
        XCTAssertTrue(V0_V1Success && V1_V2Success && V2_V3Success, "Migration failed")
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

}
