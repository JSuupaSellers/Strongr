import Foundation
import CoreData

/// Core Data implementation of UserRepository
class CoreDataUserRepository: UserRepository {
    typealias Entity = User
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAll() -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
    
    func getById(_ id: UUID) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching user by ID: \(error)")
            return nil
        }
    }
    
    func save(_ entity: User) -> User {
        saveContext()
        return entity
    }
    
    func delete(_ entity: User) {
        context.delete(entity)
        saveContext()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context in UserRepository: \(error)")
            }
        }
    }
    
    func getCurrentUser() -> User? {
        let users = getAll()
        return users.first
    }
    
    func createUser(name: String, weight: Double?, height: Double?, age: Int16?) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.name = name
        user.weight = weight ?? 0.0
        user.height = height ?? 0.0
        user.age = age ?? 0
        
        saveContext()
        return user
    }
    
    func updateUser(_ user: User, name: String?, weight: Double?, height: Double?, age: Int16?) -> User {
        if let name = name {
            user.name = name
        }
        
        if let weight = weight {
            user.weight = weight
        }
        
        if let height = height {
            user.height = height
        }
        
        if let age = age {
            user.age = age
        }
        
        saveContext()
        return user
    }
} 