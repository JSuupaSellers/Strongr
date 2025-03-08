import Foundation
import CoreData

/// Repository protocol for User entity operations
protocol UserRepository: Repository where Entity == User {
    /// Get the current active user
    func getCurrentUser() -> User?
    
    /// Create a new user with the given properties
    func createUser(name: String, weight: Double?, height: Double?, age: Int16?) -> User
    
    /// Update an existing user's properties
    func updateUser(_ user: User, name: String?, weight: Double?, height: Double?, age: Int16?) -> User
} 