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
        // Remove if exists to move to top
        recentProjects.removeAll { $0.id == project.id }
        
        recentProjects.insert(project, at: 0)
        
        // Keep only top 15 projects
        if recentProjects.count > 15 {
            recentProjects.removeLast()
        }
        
        persist()
    }
    
    func deleteProject(_ project: Project) {
        recentProjects.removeAll { $0.id == project.id }
        persist()
    }
    
    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: projectsKey),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            self.recentProjects = decoded
        }
    }
    
    private func persist() {
        if let encoded = try? JSONEncoder().encode(recentProjects) {
            UserDefaults.standard.set(encoded, forKey: projectsKey)
        }
    }
}
