import CoreData
import SwiftUI

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "StudyBuddyModel")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Concept Operations
    
    func createConcept(name: String, content: String, parentID: UUID? = nil, tags: [String] = []) -> Concept {
        let concept = Concept(context: container.viewContext)
        concept.id = UUID()
        concept.name = name
        concept.content = content
        concept.parentID = parentID
        concept.tags = tags
        concept.createdAt = Date()
        concept.masteryLevel = 0.0
        
        save()
        return concept
    }
    
    func fetchConcepts() -> [Concept] {
        let request: NSFetchRequest<Concept> = Concept.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Concept.createdAt, ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Error fetching concepts: \(error)")
            return []
        }
    }
    
    // MARK: - Review Operations
    
    func createReview(for concept: Concept, recallGrade: Int16) -> Review {
        let review = Review(context: container.viewContext)
        review.id = UUID()
        review.concept = concept
        review.recallGrade = recallGrade
        review.reviewTime = Date()
        
        // Calculate next review date using FSRS algorithm
        let nextInterval = calculateNextInterval(for: concept, recallGrade: recallGrade)
        review.intervalDays = nextInterval
        review.nextReviewDate = Calendar.current.date(byAdding: .day, value: Int(nextInterval), to: Date())
        
        // Update concept mastery level
        updateMasteryLevel(for: concept, recallGrade: recallGrade)
        
        save()
        return review
    }
    
    // MARK: - Study Session Operations
    
    func createStudySession(technique: String) -> StudySession {
        let session = StudySession(context: container.viewContext)
        session.id = UUID()
        session.startTime = Date()
        session.technique = technique
        
        save()
        return session
    }
    
    func endStudySession(_ session: StudySession) {
        session.endTime = Date()
        save()
    }
    
    // MARK: - AI Coach Operations
    
    func recordAICoachInteraction(conceptID: UUID, prompt: String, response: String) -> AICoachInteraction {
        let interaction = AICoachInteraction(context: container.viewContext)
        interaction.id = UUID()
        interaction.conceptID = conceptID
        interaction.prompt = prompt
        interaction.response = response
        interaction.interactionTime = Date()
        
        save()
        return interaction
    }
    
    // MARK: - Helper Methods
    
    private func calculateNextInterval(for concept: Concept, recallGrade: Int16) -> Double {
        // TODO: Implement FSRS v4 algorithm
        // For now, using a simple exponential backoff
        let baseInterval = 1.0
        let factor = 2.0
        let lastReview = concept.reviews?.allObjects.last as? Review
        let lastInterval = lastReview?.intervalDays ?? 0.0
        
        if recallGrade >= 3 { // Good recall
            return max(baseInterval, lastInterval * factor)
        } else { // Poor recall
            return baseInterval
        }
    }
    
    private func updateMasteryLevel(for concept: Concept, recallGrade: Int16) {
        let weight = 0.3 // Learning rate
        let targetMastery = Double(recallGrade) / 4.0 // Assuming 4-point scale
        concept.masteryLevel = (1 - weight) * (concept.masteryLevel) + weight * targetMastery
    }
    
    // MARK: - Save Context
    
    func save() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
} 