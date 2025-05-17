import Foundation
import CoreData
import SwiftUI

class ConceptListViewModel: ObservableObject {
    @Published var concepts: [Concept] = []
    @Published var currentSession: StudySession?
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        fetchConcepts()
    }
    
    func fetchConcepts() {
        concepts = coreDataManager.fetchConcepts()
    }
    
    func createConcept(name: String, content: String, parentID: UUID? = nil, tags: [String] = []) {
        let concept = coreDataManager.createConcept(name: name, content: content, parentID: parentID, tags: tags)
        concepts.insert(concept, at: 0)
    }
    
    func startStudySession(technique: String) {
        currentSession = coreDataManager.createStudySession(technique: technique)
    }
    
    func endStudySession() {
        if let session = currentSession {
            coreDataManager.endStudySession(session)
            currentSession = nil
        }
    }
    
    func recordReview(for concept: Concept, recallGrade: Int16) {
        _ = coreDataManager.createReview(for: concept, recallGrade: recallGrade)
        fetchConcepts() // Refresh to update mastery levels
    }
    
    func getDueConcepts() -> [Concept] {
        let now = Date()
        return concepts.filter { concept in
            guard let lastReview = concept.reviews?.allObjects.last as? Review,
                  let nextReviewDate = lastReview.nextReviewDate else {
                return true // New concepts are due
            }
            return nextReviewDate <= now
        }
    }
    
    func getMasteryLevel(for concept: Concept) -> Double {
        return concept.masteryLevel
    }
} 