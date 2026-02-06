import SwiftUI
import Combine

class ProjectManager: ObservableObject {
    static let shared = ProjectManager()
    
    @Published var recentProjects: [Project] = []
    private let projectsKey = "recent_projects_v2"
    
    private init() {
        loadProjects()
    }
    
    func saveProject(_ project: Project) {
        print("💾 ProjectManager: Saving project \(project.id)...")
        // Remove if exists to move to top
        recentProjects.removeAll { $0.id == project.id }
        
        recentProjects.insert(project, at: 0)
        
        // Keep only top 15 projects
        if recentProjects.count > 15 {
            recentProjects.removeLast()
        }
        
        persist()
        print("✅ ProjectManager: Project saved and persisted. Total projects: \(recentProjects.count)")
    }
    
    func deleteProject(_ project: Project) {
        recentProjects.removeAll { $0.id == project.id }
        persist()
    }
    
    func deleteProject(withId id: UUID) {
        recentProjects.removeAll { $0.id == id }
        persist()
    }
    
    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: projectsKey),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            self.recentProjects = decoded
        }
    }
    
    private func persist() {
        do {
            let encoded = try JSONEncoder().encode(recentProjects)
            UserDefaults.standard.set(encoded, forKey: projectsKey)
        } catch {
            print("❌ ProjectManager: Persistence failed - \(error.localizedDescription)")
            print("❌ Root error: \(error)")
        }
    }
}
