//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//
//

@preconcurrency import CoreData

/// The main object that manages Core Data stack and encapsulates helper methods for interaction with Core Data objects
public final class PoliteCoreStorage: Sendable {

    public enum PCError: Int, Error {

        case internalInconsistency              = 100
        case missingCurrentMOMVersionIdentifier = 102
        case invalidCurrentStoreVersion         = 103
        case momsNotFound                       = 104
        case momVersionIdentifierDuplicated     = 105
        case momVersionIdentifierMissing        = 106
        case failedInstantiateMOM               = 107
        case sourceMOMNotFound                  = 108
        case destinationMOMNotFound             = 109
        case momVersionNameDuplicated           = 110
        case customMappingModelNotFound         = 111

        public func errorDescription() -> String {
            switch self {
            case .internalInconsistency:
                return NSLocalizedString("The operation could not be completed. Internal inconsistency.", comment: "Storage Error description")
            case .missingCurrentMOMVersionIdentifier:
                return NSLocalizedString("Current model does not contain version identifier.", comment: "Storage Error description")
            case .invalidCurrentStoreVersion:
                return NSLocalizedString("Current store version is higher then current mom version.", comment: "Storage Error description")
            case .momsNotFound:
                return NSLocalizedString("Can't find moms inside container.", comment: "Storage Error description")
            case .momVersionIdentifierDuplicated:
                return NSLocalizedString("Managed object model version identifier already exists. Two or more model versions have similar identifiers.", comment: "Storage Error description")
            case .momVersionIdentifierMissing:
                return NSLocalizedString("Managed object model version identifier is missing.", comment: "Storage Error description")
            case .failedInstantiateMOM:
                return NSLocalizedString("Can't instantiate mom.", comment: "Storage Error description")
            case .sourceMOMNotFound:
                return NSLocalizedString("Can't find source mom with version identifier", comment: "Storage Error description")
            case .destinationMOMNotFound:
                return NSLocalizedString("Can't find destination mom with version identifier", comment: "Storage Error description")
            case .momVersionNameDuplicated:
                return NSLocalizedString("Managed object model version name already exists. Two or more model versions have similar names.", comment: "Storage Error description")
            case .customMappingModelNotFound:
                return NSLocalizedString("Custom mapping model not found in bundle.", comment: "Storage Error description")
            }
        }

    }

    /// Encapsulates initial setup parameters
    /// - Tag: PoliteCoreStorage.Configuration
    public struct Configuration: Sendable {

        /// A part of store directory name - "\(Configuration.sqliteStoreDirectoryPrefix).\(sqliteName)"
        public static let sqliteStoreDirectoryPrefix: String = "politeCoreStorage"

        /// The .xcdatamodeld file URL
        public let objectModelURL: URL

        /// The .sqlite file URL
        public let sqliteStoreURL: URL

        /// The store directory URL
        public let sqliteStoreDirectoryURL: URL

        /// The Bool value indicating whether the sqliteStoreDirectoryURL should be excluded from backup
        public let isExcludedFromBackup: Bool

        public let allowPersistentHistoryTracking: Bool

        public let allowPersistentStoreRemoteChangeNotificationPost: Bool

        public let isInMemory: Bool

        /// Initializes Configuration
        ///
        /// - Parameter objectModelURL: The .xcdatamodeld file URL
        /// - Parameter sqliteStoreURL: The .sqlite file URL
        /// - Parameter isExcludedFromBackup: The Bool value indicating whether the sqliteStoreDirectoryURL should be excluded from backup
        public init(objectModelURL: URL,
                    sqliteStoreURL: URL,
                    isExcludedFromBackup: Bool,
                    allowPersistentHistoryTracking: Bool = false,
                    allowPersistentStoreRemoteChangeNotificationPost: Bool = false) {
            self.objectModelURL = objectModelURL
            self.sqliteStoreURL = sqliteStoreURL
            self.sqliteStoreDirectoryURL = sqliteStoreURL.deletingLastPathComponent()
            self.isExcludedFromBackup = isExcludedFromBackup
            self.allowPersistentHistoryTracking = allowPersistentHistoryTracking
            self.allowPersistentStoreRemoteChangeNotificationPost = allowPersistentStoreRemoteChangeNotificationPost
            self.isInMemory = false
        }

        /// Initializes Configuration
        ///
        /// - Parameter objectModelName: The name of .xcdatamodeld file
        /// - Parameter isExcludedFromBackup: The Bool value indicating whether the sqliteStoreDirectoryURL should be excluded from backup
        /// - Parameter sqliteStoreFileName: The name of .sqlite file, pass nil to use objectModelName
        /// - Parameter sqliteStoreDirectoryPrefix: A part of store directory name - "\(Configuration.sqliteStoreDirectoryPrefix).\(sqliteName)". Configuration.sqliteStoreDirectoryPrefix by default
        /// - parameter isInMemory:
        public init(objectModelName: String,
                    isExcludedFromBackup: Bool,
                    sqliteStoreFileName: String? = nil,
                    sqliteStoreDirectoryPrefix: String = Configuration.sqliteStoreDirectoryPrefix,
                    allowPersistentHistoryTracking: Bool = false,
                    allowPersistentStoreRemoteChangeNotificationPost: Bool = false,
                    isInMemory: Bool) {
            let fileManager: FileManager = FileManager.default
            guard let rootDirURL: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
                  let modelURL = Bundle.main.url(forResource: objectModelName, withExtension: "momd") else {
                fatalError("Can't create root storage directory. .urls(for: .documentDirectory")
            }
            let sqliteName = sqliteStoreFileName ?? objectModelName
            let dirName = "\(sqliteStoreDirectoryPrefix).\(sqliteName)"
            let storeDirURL = rootDirURL.appendingPathComponent(dirName, isDirectory: true)
            self.sqliteStoreDirectoryURL = storeDirURL
            if isInMemory {
                self.sqliteStoreURL = URL(fileURLWithPath: "memory://store")
            } else {
                self.sqliteStoreURL = storeDirURL.appendingPathComponent("\(sqliteName).sqlite", isDirectory: false)
            }
            self.objectModelURL = modelURL
            self.isExcludedFromBackup = isExcludedFromBackup
            self.allowPersistentHistoryTracking = allowPersistentHistoryTracking
            self.allowPersistentStoreRemoteChangeNotificationPost = allowPersistentStoreRemoteChangeNotificationPost
            self.isInMemory = isInMemory
        }
    }

    public struct MigrationOrderItem: Sendable {

        public let identifier: String
        public let customMappingModelName: String?
        public let customMappingModelBundle: Bundle?

        public init(identifier: String,
                    customMappingModelName: String? = nil,
                    customMappingModelBundle: Bundle? = nil) {
            self.identifier = identifier
            self.customMappingModelName = customMappingModelName
            self.customMappingModelBundle = customMappingModelBundle
        }

    }

    /// Specifies the order of model versions to migrate.
    public enum MigrationOrder: Sendable {

        /// A model identifiers sorted in ascending order.
        case modelIdentifiers(items: [MigrationOrderItem])

        /// A model identifiers the order is defined by position in array
        case modelIdentifierList([MigrationOrderItem])

        /// A model names the order is defined by position in array
        /** - warning: Compatible versions of models with different names are considered the same,
         to avoid this behavior, add model version identifiers to such models */
        case modelNameList([MigrationOrderItem])

    }

    /// Encapsulates information about migrated model
    public struct MigrationModelVersion {

        /// The file URL of model
        public let modelURL: URL

        /// A NSManagedObjectModel instance
        public let model: NSManagedObjectModel

        /// The version identifier used during migration
        public let versionIdentifier: String?
        public var validVersionIdentifier: String {
            get throws {
                guard let versionIdentifier = versionIdentifier,
                      !versionIdentifier.isEmpty else {
                    throw PCError.momVersionIdentifierMissing
                }
                return versionIdentifier
            }
        }

        /// A file name of model without extension
        public let modelName: String

        public var customMappingModelName: String?
        public var customMappingModelBundle: Bundle?

        public init(_ modelURL: URL, modelName: String? = nil) throws {
            self.modelURL = modelURL
            guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
                throw PCError.failedInstantiateMOM
            }
            self.model = model
            self.versionIdentifier = (model.versionIdentifiers as? Set<String>)?.first
            self.modelName = modelName ?? modelURL.deletingPathExtension().lastPathComponent
        }
    }

    public enum Constant {
        /// The default fetch batch size value to use with fetch request
        static let defaultBatchSize: Int = 100
    }

    public let configuration: Configuration

    private let rootSavingContext: NSManagedObjectContext!
    private let concurrentFetchContext: NSManagedObjectContext!
    @MainActor
    private let mainQueueContext: NSManagedObjectContext!
    private let persistentStoreCoordinatorMain: NSPersistentStoreCoordinator!
    private let persistentStoreCoordinatorWorker: NSPersistentStoreCoordinator!
    private let classToEntityNameMap: [String: String]!
    @MainActor
    private var notificationsTask: Task<(), Never>?

    /// PoliteCoreStorage instance initialization according to given configuration
    ///
    /// - Parameters:
    ///   - configuration: The instance of [Configuration](x-source-tag://PoliteCoreStorage.Configuration) to use during setup
    /// - Returns: The new PoliteCoreStorage instance
    @MainActor
    public init(configuration: Configuration) {
        guard let model = NSManagedObjectModel(contentsOf: configuration.objectModelURL) else {
            fatalError("Could not initialize database object model")
        }
        self.configuration = configuration
        classToEntityNameMap = model.entitiesByName.reduce(into: [:], { (result, entry) in
            result[entry.value.managedObjectClassName] = entry.key
        })
        persistentStoreCoordinatorMain = NSPersistentStoreCoordinator(managedObjectModel: model)
        persistentStoreCoordinatorWorker = NSPersistentStoreCoordinator(managedObjectModel: model)
        rootSavingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        concurrentFetchContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        mainQueueContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }

    deinit {
        MainActor.assumeIsolated({
            removeObservers()
        })
    }

    // MARK: - Migration

    /// Migrates database to new model version synchronous
    ///
    /// - Parameters:
    ///   - migrationStep: Executed when simple migration step between neighboring models is done (e.g. 1 -> 2, 2 -> 3, 3 -> 4 ...).
    ///                    Additional data save can be performed here.
    public func migrate(migrationOrder: MigrationOrder,
                        allowPersistentHistoryTracking: Bool = false,
                        allowPersistentStoreRemoteChangeNotificationPost: Bool = false,
                        migrationStep: (@Sendable (_ fromVersion: MigrationModelVersion,
                                                   _ toVersion: MigrationModelVersion) async -> Void)?) async throws {
        let storeURL = configuration.sqliteStoreURL

        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            // Migration is not needed. Nothing to migrate
            return
        }

        let containerURL = configuration.objectModelURL

        let destinationVersionModelName: String
        if let currentVersionURL = Bundle.main.url(forResource: "VersionInfo", withExtension: "plist", subdirectory: configuration.objectModelURL.lastPathComponent),
           let plistData = try? Data(contentsOf: currentVersionURL),
           let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] {
            destinationVersionModelName = plist["NSManagedObjectModel_CurrentVersionName"] as? String ?? ""
        } else {
            destinationVersionModelName = ""
        }
        let destinationVersion = try MigrationModelVersion(containerURL, modelName: destinationVersionModelName)
        let storeMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL)
        let storeVersionIdentifier = (storeMetadata["NSStoreModelVersionIdentifiers"] as? [String])?.first
        guard !destinationVersion.model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata) ||
                storeVersionIdentifier != destinationVersion.versionIdentifier else {
            // Migration is not needed.
            return
        }
        let migrationMap = try migrationModelVersionMap(order: migrationOrder,
                                                        storeMetadata: storeMetadata,
                                                        destinationVersion: destinationVersion)
        guard migrationMap.count >= 2 else {
            throw PCError.destinationMOMNotFound
        }

        for index in 0..<(migrationMap.count - 1) {
            let source = migrationMap[index]
            let destination = migrationMap[index + 1]
            try migrateStore(storeURL: storeURL,
                             sourceMOM: source.model,
                             destinationMOM: destination.model,
                             customMappingModelName: source.customMappingModelName,
                             customMappingModelBundle: source.customMappingModelBundle,
                             allowPersistentHistoryTracking: allowPersistentHistoryTracking,
                             allowPersistentStoreRemoteChangeNotificationPost: allowPersistentStoreRemoteChangeNotificationPost)
            await migrationStep?(source, destination)
        }
    }

    // MARK: - Setup

    /// Creates PoliteCoreStorage instance synchronous
    ///
    /// - Parameters:
    ///   - removeDBOnSetupFailed: Pass true to remove DB files and recreate from scratch in case of setup failed
    @MainActor
    public func setupStack(removeDBOnSetupFailed: Bool) throws {
        do {
            try setupCoreDataStack(removeOldDB: false)
        } catch let error {
            if removeDBOnSetupFailed {
                try setupCoreDataStack(removeOldDB: true)
            } else {
                throw error
            }
        }
    }

    /// Creates PoliteCoreStorage instance asynchronous
    ///
    /// - Parameters:
    ///   - removeDBOnSetupFailed: Pass true to remove DB files and recreate from scratch in case of setup failed
    @MainActor
    public func setupStack(removeDBOnSetupFailed: Bool) async throws {
        do {
            try await setupCoreDataStack(removeOldDB: false)
        } catch let error {
            if removeDBOnSetupFailed {
                try await setupCoreDataStack(removeOldDB: true)
            } else {
                throw error
            }
        }
    }

    // MARK: - Maintenance

    /// Calls reset() on main queue context
    @MainActor
    public func resetMainQueueContext() {
        mainQueueContext.reset()
    }

    /// Calls reset() on private queue rootSavingContext
    public func resetRootSavingContext() async {
        await rootSavingContext.perform({
            self.rootSavingContext.reset()
        })
    }

}

// MARK: - Public

// MARK: Main Queue context methods

public extension PoliteCoreStorage {

    /// Returns an entity for the specified objectID or nil if the object does not exist.
    /// See also [existingObject](x-source-tag://existingObjectWithID)
    ///
    /// - Parameter objectID: The NSManagedObjectID for the specified entity
    /// - Returns: An entity for the specified objectID or nil
    /// - Warning: To use on main queue only!
    @MainActor
    func existingEntityInMainQueueContext<T: NSManagedObject>(objectID: NSManagedObjectID) -> T? {
        return existingEntity(objectID: objectID, context: mainQueueContext)
    }

    @MainActor
    func executeInMainQueueContext<T>(request: NSFetchRequest<T>) throws -> [T] {
        return try execute(request: request, context: mainQueueContext)
    }

    /// Returns an entity for the specified predicate or nil if the object does not exist.
    /// See also [findFirst](x-source-tag://findFirst)
    ///
    /// - Parameters:
    ///   - entityType: A type of entity to find
    ///   - predicate: NSPredicate object that describes entity
    /// - Returns: First found entity or nil
    /// - Warning: To use on main queue only!
    @MainActor
    func findFirstInMainQueueContext<T: NSManagedObject>(entityType: T.Type, predicate: NSPredicate?) throws -> T? {
        return try findFirst(entityType: entityType, predicate: predicate, context: mainQueueContext)
    }

    /// Finds all entities with given type. Optionally filterred by predicate
    /// See also [findAll](x-source-tag://findAll)
    ///
    /// - Parameters:
    ///   - entityType: A type of entity to find
    ///   - sortDescriptors: An array of NSSortDescriptor
    ///   - predicate: predicate to filter by
    /// - Returns: Array of entities
    /// - Warning: To use on main queue only!
    @MainActor
    func findAllInMainQueueContext<T: NSManagedObject>(entityType: T.Type,
                                                       sortDescriptors: [NSSortDescriptor]? = nil,
                                                       predicate: NSPredicate? = nil) throws -> [T] {
        return try findAll(entityType: entityType, context: mainQueueContext, sortDescriptors: sortDescriptors, predicate: predicate)
    }

    /// Returns new NSFetchedResultsController for using in main queue.
    ///
    /// - Parameters:
    ///   - entityType: A type of entity to fetch
    ///   - sortDescriptors: An array of NSSortDescriptor
    ///   - predicate: predicate to filter by
    ///   - sectionNameKeyPath: Key path to group by, pass nil to indicate that the controller should generate a single section.
    ///   - cacheName: The name of the cache file the receiver should use. Pass nil to prevent caching.
    ///   - configureRequest: A closure that takes a NSFetchRequest as a parameter, can be used to customize the request.
    /// - Returns: A NSFetchedResultsController instance
    /// - Warning: To use on main queue only!
    @MainActor
    func mainQueueFetchedResultsController<T: NSManagedObject>(entityType: T.Type,
                                                               sortDescriptors: [NSSortDescriptor],
                                                               predicate: NSPredicate? = nil,
                                                               sectionNameKeyPath: String? = nil,
                                                               cacheName: String? = nil,
                                                               fetchBatchSize: Int? = nil,
                                                               relationshipKeyPathsForPrefetching: [String]? = nil,
                                                               configureRequest: ((_ request: NSFetchRequest<T>) -> Void)?) -> NSFetchedResultsController<T> {
        assert(Thread.current.isMainThread, "Access to mainQueueContext in BG thread")
        let request = createRequest(entityType: entityType, sortDescriptors: sortDescriptors, predicate: predicate)
        request.fetchBatchSize = fetchBatchSize ?? Constant.defaultBatchSize
        request.returnsObjectsAsFaults = false
        request.includesPropertyValues = true
        request.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
        configureRequest?(request)

        let resultsController: NSFetchedResultsController<T> = NSFetchedResultsController(fetchRequest: request,
                                                                                          managedObjectContext: mainQueueContext,
                                                                                          sectionNameKeyPath: sectionNameKeyPath,
                                                                                          cacheName: cacheName)
        return resultsController
    }

    /// Returns the number of entities according to the given predicate.
    /// See also [countForEntity](x-source-tag://countForEntity)
    ///
    /// - Parameters:
    ///   - entityType: A type of entity to fetch
    ///   - predicate: NSPredicate to filter by
    /// - Returns: Returns the number of entities.
    /// - Warning: To use on main queue only!
    @MainActor
    func countForEntityInMainQueueContext<T: NSManagedObject>(entityType: T.Type, predicate: NSPredicate? = nil) throws -> Int {
        return try count(entityType: entityType, context: mainQueueContext, predicate: predicate)
    }

}

// MARK: Save/Create

public extension PoliteCoreStorage {

    /// Performs block on private queue of saving context.
    ///
    /// - Parameters:
    ///   - body: A closure that takes a context as a parameter. Will be executed on private context queue. Caller could apply any changes to DB in it. At the end of execution context will be saved.
    /// - Tag: save
    func save<Result>(_ body: @escaping @Sendable (_ context: NSManagedObjectContext) throws -> Result) async throws -> Result {
        return try await saveContext(rootSavingContext, changesBlock: body)
    }

    /// Finds first entity that matches predicate, or creates new one if no entity found
    /// See also: [findFirstByIdOrCreate](x-source-tag://findFirstByIdOrCreate)
    ///
    /// - Parameters:
    ///   - entityType: A type of entity to find
    ///   - predicate: NSPredicate object that describes entity
    ///   - context:  NSManagedObjectContext where entity should be find
    /// - Returns: First found or created entity, never returns nil
    /// - Tag: findFirstOrCreate
    func findFirstOrCreate<T: NSManagedObject>(entityType: T.Type, predicate: NSPredicate, context: NSManagedObjectContext) throws -> T {
        if let object: T = try findFirst(entityType: entityType, predicate: predicate, context: context) {
            return object
        }
        return create(entityType: entityType, context: context)
    }

    /// Finds entity name by given type
    /// - Parameter entityType: A type of entity to find name by
    func entityName<T: NSManagedObject>(entityType: T.Type) -> String {
        let className = NSStringFromClass(entityType)
        guard let entityName: String = classToEntityNameMap[className] else {
            fatalError("Entity name not found for class name \"\(className)\"")
        }
        return entityName
    }

    /// Creates entity of given type
    /// - Parameters:
    ///   - entityType: A type of entity to create
    ///   - context: A context where entity should be created
    func create<T: NSManagedObject>(entityType: T.Type, context: NSManagedObjectContext) -> T {
        let name = entityName(entityType: entityType)
        guard let entity: T = NSEntityDescription.insertNewObject(forEntityName: name, into: context) as? T else {
            fatalError("\(type(of: self)) - \(#function): . \(name)")
        }
        return entity
    }

    /// Creates new NSFetchRequest
    /// - Parameters:
    ///   - entityType: The type of the entity to fetch.
    ///   - sortDescriptors: The sort descriptors of the fetch request.
    ///   - predicate: The predicate of the fetch request.
    func createRequest<T: NSManagedObject>(entityType: T.Type,
                                           sortDescriptors: [NSSortDescriptor]? = nil,
                                           predicate: NSPredicate? = nil) -> NSFetchRequest<T> {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: entityName(entityType: entityType))
        request.includesPendingChanges = true
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        return request
    }

    /// Executes NSFetchRequest
    /// - Parameters:
    ///   - request: NSFetchRequest to execute.
    ///   - context: The target NSManagedObjectContext
    /// - Returns: Array of fetched objects.
    func execute<T>(request: NSFetchRequest<T>, context: NSManagedObjectContext) throws -> [T] {
        do {
            let results: [T] = try context.fetch(request)
            return results
        } catch let error {
            assertionFailure("Can't execute Fetch Request \(error)")
            throw error
        }
    }

}

// MARK: General

public extension PoliteCoreStorage {

    /// Could be used to fetch objects in the background for temporary usage, context will be resete directly after "block:" execution
    ///
    /// - Parameters:
    ///   - body: A closure that takes a context as a parameter.
    /// - Tag: fetch
    func fetch<ResultType>(_ body: @escaping @Sendable ((_ context: NSManagedObjectContext) throws -> ResultType)) async throws -> ResultType {
        let fetchContext: NSManagedObjectContext = concurrentFetchContext
        return try await fetchContext.perform({
            do {
                let result = try body(fetchContext)
                fetchContext.reset()
                return result
            } catch let error {
                fetchContext.reset()
                assertionFailure("Could not fetch: \(error)")
                throw error
            }
        })
    }

    /// Returns entity for the specified objectID or nil if entity does not exist.
    ///
    /// - Parameters:
    ///   - objectID: The Object ID for the requested entity.
    ///   - context: target NSManagedObjectContext.
    /// - Returns: Entity specified by objectID. If entity cannot be fetched, or does not exist, or cannot be faulted, it returns nil.
    /// - Tag: existingObjectWithID
    func existingEntity<T: NSManagedObject>(objectID: NSManagedObjectID, context: NSManagedObjectContext) -> T? {
        var object: T?
        do {
            try object = context.existingObject(with: objectID) as? T
        } catch let error as NSError {
            debugPrint("Entity with provided ID does not exist, or cannot be faulted error: \(error)")
            assertionFailure()
        }
        return object
    }

    /// Returns an entity for the specified predicate or nil if the object does not exist.
    ///
    /// - Parameters:
    ///   - entityType: A type of entity to find
    ///   - predicate: NSPredicate object that describes entity
    ///   - context: The target context
    /// - Returns: First found entity or nil
    /// - Tag: findFirst
    func findFirst<T: NSManagedObject>(entityType: T.Type, predicate: NSPredicate?, context: NSManagedObjectContext) throws -> T? {
        let request = createRequest(entityType: entityType, predicate: predicate)
        request.fetchLimit = 1
        return try execute(request: request, context: context).first
    }

    /// Finds all entities with given type. Optionally filterred by predicate
    ///
    /// - Parameters:
    ///   - entityType: A type of entity to find
    ///   - context: The target context
    ///   - sortDescriptors: An array of NSSortDescriptor
    ///   - predicate: predicate to filter by
    /// - Returns: Array of entities
    /// - Tag: findAll
    func findAll<T: NSManagedObject>(entityType: T.Type,
                                     context: NSManagedObjectContext,
                                     sortDescriptors: [NSSortDescriptor]? = nil,
                                     predicate: NSPredicate? = nil) throws -> [T] {
        let request = createRequest(entityType: entityType, sortDescriptors: sortDescriptors, predicate: predicate)
        return try execute(request: request, context: context)
    }

    /// Returns the number of entities according to the given predicate.
    ///
    /// - Parameters:
    ///   - entityType: A type of entity to fetch
    ///   - context: The target context
    ///   - predicate: NSPredicate to filter by
    /// - Returns: Returns the number of entities.
    /// - Tag: countForEntity
    func count<T: NSManagedObject>(entityType: T.Type, context: NSManagedObjectContext, predicate: NSPredicate? = nil) throws -> Int {
        let request = createRequest(entityType: entityType, predicate: predicate)
        request.resultType = .managedObjectIDResultType
        return try count(request: request, context: context)
    }

    /// Returns the number of entities according to the given fetch request.
    ///
    /// - Parameters:
    ///   - request: NSFetchRequest to execute
    ///   - context: The target context
    /// - Returns: Returns the number of entities.
    /// - Tag: countForFetchRequest
    func count<T: NSManagedObject>(request: NSFetchRequest<T>, context: NSManagedObjectContext) throws -> Int {
        do {
            let result: Int = try context.count(for: request)
            return result
        } catch let error {
            assertionFailure("Can't execute Fetch Request \(error)")
            throw error
        }
    }

    func fetchPersistentHistoryTransactionsForLastMinute() async throws -> [NSPersistentHistoryTransaction] {
        return try await fetch({ (context) in
            let fetchHistoryRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: Date(timeIntervalSinceNow: -60))
            guard let historyResult = try? context.execute(fetchHistoryRequest) as? NSPersistentHistoryResult,
                  let historyTransactions = historyResult.result as? [NSPersistentHistoryTransaction]
            else {
                fatalError("Could not convert history result to transactions.")
            }
            return historyTransactions
        })
    }

    func removeSqliteStoreDirectory() {
        let storeDirURL: URL = configuration.sqliteStoreDirectoryURL
        let fileManager: FileManager = FileManager.default
        if fileManager.fileExists(atPath: storeDirURL.path) {
            try? fileManager.removeItem(at: storeDirURL)
        }
    }

}

// MARK: - Private

private extension PoliteCoreStorage {

    // MARK: Setup

    @MainActor
    private func setupCoreDataStack(removeOldDB: Bool) throws {
        setupCoreDataContexts()
        if !configuration.isInMemory {
            makeRootStorageDirectory(removeOldDB: removeOldDB)
        }
        try addPersistentStores()
    }

    @MainActor
    private func setupCoreDataStack(removeOldDB: Bool) async throws {
        setupCoreDataContexts()
        if !configuration.isInMemory {
            makeRootStorageDirectory(removeOldDB: removeOldDB)
        }
        try await Task(operation: {
            try self.addPersistentStores()
        }).value
    }

    @MainActor
    private func setupCoreDataContexts() {
        // Setup context
        self.rootSavingContext.mergePolicy = NSMergePolicy.overwrite
        self.rootSavingContext.undoManager = nil
        if configuration.isInMemory {
            // same store, because they are created in memory, so thay can not sync by URL
            self.rootSavingContext.persistentStoreCoordinator = self.persistentStoreCoordinatorMain
        } else {
            self.rootSavingContext.persistentStoreCoordinator = self.persistentStoreCoordinatorWorker
        }

        self.concurrentFetchContext.parent = self.rootSavingContext
        self.concurrentFetchContext.undoManager = nil

        self.mainQueueContext.undoManager = nil
        self.mainQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinatorMain

        self.addObservers()
    }

    private func addPersistentStores() throws {
        let storeURL = configuration.sqliteStoreURL
        var options: [AnyHashable: Any] = [NSMigratePersistentStoresAutomaticallyOption: true,
                                                 NSInferMappingModelAutomaticallyOption: true]
        if configuration.isInMemory {
            try persistentStoreCoordinatorMain.addPersistentStore(ofType: NSInMemoryStoreType,
                                                                  configurationName: nil,
                                                                  at: storeURL,
                                                                  options: options)
        } else {
            try persistentStoreCoordinatorMain.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                  configurationName: nil,
                                                                  at: storeURL,
                                                                  options: options)
        }
        // https://developer.apple.com/documentation/coredata/consuming_relevant_store_changes
        if configuration.allowPersistentHistoryTracking {
            options[NSPersistentHistoryTrackingKey] = true
        }
        if configuration.allowPersistentStoreRemoteChangeNotificationPost {
            options[NSPersistentStoreRemoteChangeNotificationPostOptionKey] = true
        }
        if configuration.isInMemory {
            try persistentStoreCoordinatorWorker.addPersistentStore(ofType: NSInMemoryStoreType,
                                                                    configurationName: nil,
                                                                    at: storeURL,
                                                                    options: options)
        } else {
            try persistentStoreCoordinatorWorker.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                    configurationName: nil,
                                                                    at: storeURL,
                                                                    options: options)
        }
    }

    // MARK: Migration

    /// Caretes migration map,  order of migration is defined by position in array
    /// - Parameters:
    ///   - order: A MigrationOrder instance
    ///   - storeMetadata: The srore metadata, used to find store model version
    ///   - destinationVersion: A MigrationModelVersion instance, distination version
    private func migrationModelVersionMap(order: MigrationOrder,
                                          storeMetadata: [String: Any],
                                          destinationVersion: MigrationModelVersion) throws -> [MigrationModelVersion] {
        guard let modelsURLs = Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory: configuration.objectModelURL.lastPathComponent),
              !modelsURLs.isEmpty else {
            throw PCError.momsNotFound
        }

        switch order {
        case .modelIdentifiers(let items):
            let modelVersions = try modelVersions(modelsURLs: modelsURLs,
                                                  storeMetadata: storeMetadata,
                                                  items: items)
            let destIdentifier = try destinationVersion.validVersionIdentifier
            let sourceIdentifier = try modelVersions.storeVersion.validVersionIdentifier
            let result: [MigrationModelVersion] = try modelVersions.versions.filter({ modelVersion in
                let currentIdentifier = try modelVersion.validVersionIdentifier
                let destResult = currentIdentifier.compare(destIdentifier, options: .numeric)
                let srcResult = currentIdentifier.compare(sourceIdentifier, options: .numeric)
                let result = (srcResult == .orderedDescending || srcResult == .orderedSame) && (destResult == .orderedAscending || destResult == .orderedSame)
                return result
            }).sorted(by: { lhs, rhs in
                let lhsId = try lhs.validVersionIdentifier
                let rhsId = try rhs.validVersionIdentifier
                guard lhsId != rhsId else {
                    throw PCError.momVersionIdentifierDuplicated
                }
                return lhsId.compare(rhsId, options: .numeric) == .orderedAscending
            })
            return result

        case .modelIdentifierList(let items):
            let versions = try modelVersionMap(modelsURLs: modelsURLs,
                                               storeMetadata: storeMetadata,
                                               nameBased: false,
                                               items: items)
            let storeVersion = versions.storeVersion
            let versionsMap = versions.versions
            guard let indexOfStoreVersion = items.firstIndex(where: { $0.identifier == storeVersion.versionIdentifier }) else {
                throw PCError.sourceMOMNotFound
            }
            let result: [MigrationModelVersion] = items[indexOfStoreVersion..<items.endIndex].compactMap({ versionsMap[$0.identifier] })
            return result

        case .modelNameList(let items):
            let versions = try modelVersionMap(modelsURLs: modelsURLs,
                                               storeMetadata: storeMetadata,
                                               nameBased: true,
                                               items: items)
            let storeVersion = versions.storeVersion
            let versionsMap = versions.versions
            guard let indexOfStoreVersion = items.firstIndex(where: { $0.identifier == storeVersion.modelName }) else {
                throw PCError.sourceMOMNotFound
            }
            let result: [MigrationModelVersion] = items[indexOfStoreVersion..<items.endIndex].compactMap({ versionsMap[$0.identifier] })
            return result
        }
    }

    private func modelVersionMap(
        modelsURLs: [URL],
        storeMetadata: [String: Any],
        nameBased: Bool,
        items: [PoliteCoreStorage.MigrationOrderItem]) throws -> (storeVersion: MigrationModelVersion, versions: [String: MigrationModelVersion]) {
            var storeVersion: MigrationModelVersion?
            let storeVersionIdentifier = (storeMetadata["NSStoreModelVersionIdentifiers"] as? [String])?.first
            let resultMap: [String: MigrationModelVersion] = try modelsURLs.reduce(into: [:], { (result, modelURL) in
                var modelVersion = try MigrationModelVersion(modelURL)
                let item = items.first(where: { (item) in
                    return item.identifier == modelVersion.modelName || item.identifier == modelVersion.versionIdentifier
                })
                modelVersion.customMappingModelName = item?.customMappingModelName
                modelVersion.customMappingModelBundle = item?.customMappingModelBundle
                let mapKey: String
                mapKey = nameBased ? modelVersion.modelName : try modelVersion.validVersionIdentifier
                guard result[mapKey] == nil else { throw PCError.momVersionIdentifierDuplicated }
                if storeVersion == nil,
                   modelVersion.model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata),
                   storeVersionIdentifier == modelVersion.versionIdentifier {
                    storeVersion = modelVersion
                }
                result[mapKey] = modelVersion
            })
            guard let storeVersion = storeVersion else {
                throw PCError.sourceMOMNotFound
            }
            return (storeVersion, resultMap)
        }

    private func modelVersions(
        modelsURLs: [URL],
        storeMetadata: [String: Any],
        items: [PoliteCoreStorage.MigrationOrderItem]) throws -> (storeVersion: MigrationModelVersion, versions: [MigrationModelVersion]) {
        var storeVersion: MigrationModelVersion?
        let storeVersionIdentifier = (storeMetadata["NSStoreModelVersionIdentifiers"] as? [String])?.first
        let result: [MigrationModelVersion] = try modelsURLs.reduce(into: [], { (result, modelURL) in
            var modelVersion = try MigrationModelVersion(modelURL)
            let item = try items.first(where: { (item) in
                let validVersionIdentifier = try modelVersion.validVersionIdentifier
                return item.identifier == validVersionIdentifier
            })
            modelVersion.customMappingModelName = item?.customMappingModelName
            modelVersion.customMappingModelBundle = item?.customMappingModelBundle
            if storeVersion == nil,
               modelVersion.model.isConfiguration(withName: nil, compatibleWithStoreMetadata: storeMetadata),
               storeVersionIdentifier == modelVersion.versionIdentifier {
                storeVersion = modelVersion
            }
            result.append(modelVersion)
        })
        guard let storeVersion = storeVersion else {
            throw PCError.sourceMOMNotFound
        }
        return (storeVersion: storeVersion, result)
    }

    private func migrateStore(storeURL: URL,
                              sourceMOM: NSManagedObjectModel,
                              destinationMOM: NSManagedObjectModel,
                              customMappingModelName: String?,
                              customMappingModelBundle: Bundle?,
                              allowPersistentHistoryTracking: Bool,
                              allowPersistentStoreRemoteChangeNotificationPost: Bool) throws {
        let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true, attributes: nil)
        defer {
            _ = try? FileManager.default.removeItem(at: temporaryDirectory)
        }
        // find mapping model
        let mappingModel: NSMappingModel
        if let customMappingModelNameActual = customMappingModelName {
            let bundle = customMappingModelBundle ?? Bundle.main
            if let url = bundle.url(forResource: customMappingModelNameActual, withExtension: "cdm"),
               let customMapping = NSMappingModel(contentsOf: url) {
                mappingModel = customMapping
            } else {
                debugPrint("Custom mapping modelNotFound: \(customMappingModelNameActual)")
                throw PCError.customMappingModelNotFound
            }
        } else {
            mappingModel = try NSMappingModel.inferredMappingModel(forSourceModel: sourceMOM, destinationModel: destinationMOM)
        }
        // perfom migration and save result to temporary folder
        let destinationURL = temporaryDirectory.appendingPathComponent(storeURL.lastPathComponent)
        let manager = NSMigrationManager(sourceModel: sourceMOM, destinationModel: destinationMOM)
        try autoreleasepool {
            var options: [AnyHashable: Any] = [:]
            if allowPersistentHistoryTracking {
                options[NSPersistentHistoryTrackingKey] = true
            }
            if allowPersistentStoreRemoteChangeNotificationPost {
                options[NSPersistentStoreRemoteChangeNotificationPostOptionKey] = true
            }
            try manager.migrateStore(from: storeURL,
                                     type: .sqlite,
                                     options: options,
                                     mapping: mappingModel,
                                     to: destinationURL,
                                     type: .sqlite,
                                     options: options)
        }
        // move migration result from temporary folder to destination folder
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: destinationMOM)
        try persistentStoreCoordinator.replacePersistentStore(at: storeURL, withPersistentStoreFrom: destinationURL, type: .sqlite)
    }

    private func makeRootStorageDirectory(removeOldDB: Bool) {
        let fileManager: FileManager = FileManager.default
        let storeDirURL: URL = configuration.sqliteStoreDirectoryURL
        let isExcludedFromBackup = configuration.isExcludedFromBackup
        if removeOldDB {
            try? fileManager.removeItem(at: storeDirURL)
        }
        do {
            try fileManager.createDirectory(at: storeDirURL, withIntermediateDirectories: true, attributes: nil)
            setExcludedFromBackup(url: storeDirURL, isExcluded: isExcludedFromBackup)
        } catch let error as NSError {
            if error.code != NSFileWriteFileExistsError {
                assertionFailure("Can't create or excluded from backup root storage directory. error:\(error)")
            } else {
                setExcludedFromBackup(url: storeDirURL, isExcluded: isExcludedFromBackup)
            }
        }
    }

    private func setExcludedFromBackup(url: URL, isExcluded: Bool) {
        do {
            var currentURL = url
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = isExcluded
            try currentURL.setResourceValues(resourceValues)
        } catch let error as NSError {
            if error.code != NSFileWriteFileExistsError {
                assertionFailure("Can't set isExcludedFromBackup resource value for url \(url). error:\(error)")
            }
        }
    }

    // MARK: Helpers

    private func saveContext<Result>(_ context: NSManagedObjectContext,
                                     changesBlock: @escaping @Sendable (_ context: NSManagedObjectContext) throws -> Result) async throws -> Result {
        return try await context.perform(schedule: .enqueued, {
            context.reset()
            do {
                let result = try changesBlock(context)
                if result is NSManagedObject {
                    assertionFailure("NSManagedObject not allowed as result.")
                }
                guard context.hasChanges else {
                    return result
                }
                try context.save()
                context.reset()
                return result
            } catch let error {
                context.reset()
                assertionFailure("Could not save context \(error)")
                throw error
            }
        })
    }

    // MARK: - Observing

    @MainActor
    private func addObservers() {
        if rootSavingContext == nil || mainQueueContext == nil {
            return
        }
        removeObservers()
        let notificationCenter = NotificationCenter.default
        notificationsTask = Task(operation: { @MainActor [weak self] in
            let notificationsData = notificationCenter.notifications(named: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                .map({ NotificationData(name: $0.name, object: $0.object, userInfo: $0.userInfo) })
            for await notificationData in notificationsData {
                guard let context = notificationData.object as? NSManagedObjectContext, context === self?.rootSavingContext else {
                    return
                }
                let mainQueueContext = self?.mainQueueContext
                if let updatedObjects = notificationData.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
                    for object in updatedObjects {
                        do {
                            try mainQueueContext?.existingObject(with: object.objectID).willAccessValue(forKey: nil)
                        } catch {
                            // do nothing
                        }
                    }
                }
                let notification = Notification(name: notificationData.name, object: notificationData.object, userInfo: notificationData.userInfo)
                mainQueueContext?.mergeChanges(fromContextDidSave: notification)
            }
        })
        notificationCenter.addObserver(self,
                                       selector: #selector(contextWillSave(_:)),
                                       name: NSNotification.Name.NSManagedObjectContextWillSave,
                                       object: rootSavingContext)
        notificationCenter.addObserver(self,
                                       selector: #selector(contextWillSave(_:)),
                                       name: NSNotification.Name.NSManagedObjectContextWillSave,
                                       object: mainQueueContext)
        notificationCenter.addObserver(self,
                                       selector: #selector(contextWillSave(_:)),
                                       name: NSNotification.Name.NSManagedObjectContextWillSave,
                                       object: concurrentFetchContext)
    }

    @MainActor
    private func removeObservers() {
        if rootSavingContext == nil || mainQueueContext == nil {
            return
        }
        notificationsTask?.cancel()
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextWillSave, object: rootSavingContext)
        notificationCenter.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextWillSave, object: mainQueueContext)
        notificationCenter.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextWillSave, object: concurrentFetchContext)
    }

    @objc
    private func contextWillSave(_ notification: Notification) {
        if let context = notification.object as? NSManagedObjectContext {
            assert(context === rootSavingContext, "Attempt to save the wrong context \(context)")
            if !context.insertedObjects.isEmpty {
                do {
                    try context.obtainPermanentIDs(for: Array(context.insertedObjects))
                } catch {
                    // do nothing
                }
            }
        }
    }

}

// Notification is not Sendable because userInfo contains Any. To fix compiler error we use @unchecked Sendable.
// We should check interfaces in new iOS releases.
private struct NotificationData: @unchecked Sendable {
    let name: Notification.Name
    let object: Any?
    let userInfo: [AnyHashable: Any]?
}
