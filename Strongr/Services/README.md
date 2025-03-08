# Repository Pattern and Service Layer

This directory contains the repository pattern and service layer implementations for the Strongr app.

## Repository Pattern

The repository pattern provides an abstraction layer between the data layer (Core Data) and the business logic of the app. This helps to decouple the application from specific data access technologies, making it more maintainable and testable.

### Key Benefits

- **Separation of Concerns**: Repositories separate data access logic from business logic
- **Testability**: Services can be tested independently with mock repositories
- **Flexibility**: The data source can be changed without affecting the rest of the application
- **Maintainability**: Code is more organized and easier to understand

### Repository Structure

Each repository follows a consistent interface pattern:

- `Repository<Entity>`: A generic repository protocol with common CRUD operations
- Entity-specific repository protocols: Specialized interfaces for each entity
- Core Data implementations: Concrete implementations using Core Data

## Services

Services encapsulate business logic and use repositories to access data. They provide a higher-level API for the application.

### Available Services

- **DataSeedingService**: Handles seeding default data for first-time app launch
- **StatsService**: Provides statistics and analytics functionality
- **WorkoutService**: Manages workout-related business logic
- **UnitService**: Handles unit conversion and preferences

## Service Locator

The `ServiceLocator` class provides centralized access to all repositories and services in the application. It follows the service locator pattern to manage dependencies.

## Usage Example

```swift
// Access repositories and services through the ServiceLocator
let userRepository = ServiceLocator.shared.userRepository
let user = userRepository.getCurrentUser()

// Use a service
let statsService = ServiceLocator.shared.statsService
let totalVolume = statsService.getTotalVolumeLifted(for: user, in: nil)
```

## Migration from DataManager

The app is currently in a transition phase from the monolithic `DataManager` to the repository pattern. The `DataManager` is being maintained for backward compatibility but is deprecated.

New code should use the repositories and services directly through the `ServiceLocator`. 