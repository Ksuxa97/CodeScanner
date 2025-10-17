//
//  StorageManager.swift
//  CodeScanner
//
//  Created by Kseniya Semenova on 16.10.2025.
//

import Foundation
import CoreData

protocol StorageManagerProtocol {
    func fetch() async throws -> [ScannedCodeModel]
    func exists(code: String) -> Bool
    func save(model: ScannedCodeModel) async throws -> Void
    func updateCustomName(code: String, name: String) async throws
    func delete(code: String) async throws
}

final class StorageManager: StorageManagerProtocol, ObservableObject {
    static let shared = StorageManager()
    private let viewContext: NSManagedObjectContext
    private let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

    private init() {
        let container = NSPersistentContainer(name: "CodeScanner")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data init failed: \(error)")
            }
        }
        viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true

        backgroundContext.parent = viewContext
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func fetch() async throws -> [ScannedCodeModel] {
        return try await backgroundContext.perform { [weak self] in
            guard let self else { return [] }
            let fetchRequest = ScannedCodeEntity.fetchRequest()

            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            backgroundContext.refreshAllObjects()

            let entities = try backgroundContext.fetch(fetchRequest)
            return entities.map { $0.toScannedCodeModel() }
        }
    }

    func exists(code: String) -> Bool {
        let request = ScannedCodeEntity.fetchRequest()
        request.predicate = NSPredicate(format: "code == %@", code)
        request.fetchLimit = 1
        request.resultType = .countResultType
        do {
            let count = try viewContext.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }

    func save(model: ScannedCodeModel) async throws {
        if exists(code: model.code) { return }

        try await backgroundContext.perform { [weak self] in
            guard let self else { return }

            let entity = ScannedCodeEntity(context: backgroundContext)
            entity.code = model.code
            entity.type = model.type == .qr ? "qr" : "barcode"
            entity.customName = model.customName
            entity.title = model.title
            entity.brand = model.brand
            entity.nutriScore = model.nutriScore
            entity.rawContent = model.rawContent
            entity.date = model.date

            try backgroundContext.save()
        }

        try await self.viewContext.perform {
            try self.viewContext.save()
        }
    }

    func updateCustomName(code: String, name: String) async throws {
        try await backgroundContext.perform { [weak self] in
            guard let self else { return }

            let request = ScannedCodeEntity.fetchRequest()
            request.predicate = NSPredicate(format: "code == %@", code)
            request.fetchLimit = 1
            guard let entity = try backgroundContext.fetch(request).first else { return }
            entity.setValue(name, forKey: "customName")

            try self.backgroundContext.save()
        }

        try await self.viewContext.perform {
            try self.viewContext.save()
        }
    }

    func delete(code: String) async throws {
        try await backgroundContext.perform { [weak self] in
            guard let self else { return }
            let request = ScannedCodeEntity.fetchRequest()
            request.predicate = NSPredicate(format: "code == %@", code)
            request.fetchLimit = 1
            guard let entity = try backgroundContext.fetch(request).first else { return }
            backgroundContext.delete(entity)
            try self.backgroundContext.save()
        }

        try await self.viewContext.perform {
            try self.viewContext.save()
        }
    }
}
