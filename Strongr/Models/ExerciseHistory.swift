import Foundation
import CoreData

@objc(ExerciseHistory)
public class ExerciseHistory: NSManagedObject {

}

extension ExerciseHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseHistory> {
        return NSFetchRequest<ExerciseHistory>(entityName: "ExerciseHistory")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var originalWorkoutID: UUID?
    @NSManaged public var name: String?
    @NSManaged public var date: Date?
    @NSManaged public var duration: Double
    @NSManaged public var notes: String?
    @NSManaged public var csvSetData: String?

}

extension ExerciseHistory : Identifiable {

}
