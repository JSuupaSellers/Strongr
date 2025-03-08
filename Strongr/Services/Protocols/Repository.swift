import Foundation
import CoreData

/// Generic repository protocol defining common CRUD operations
protocol Repository {
    associatedtype Entity
    
    /// Fetch all entities
    func getAll() -> [Entity]
    
    /// Fetch entity by ID
    func getById(_ id: UUID) -> Entity?
    
    /// Create or update an entity
    func save(_ entity: Entity) -> Entity
    
    /// Delete an entity
    func delete(_ entity: Entity)
    
    /// Save context changes
    func saveContext()
} 