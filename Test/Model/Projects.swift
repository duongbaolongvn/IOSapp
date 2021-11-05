//
//  Projects.swift
//  Test
//
//  Created by Duong Bao Long on 10/11/21.
//

import Foundation
import Alamofire

class Projects {
    //    var result = 0
    var projects: [Project] = []
    
    static let main = Projects()
    
    static let projectDidLoadKey = "getProjectsDone"
    
    init() {
        loadProject()
        
    }
    
    func addProject(_ name: String) {
        let newItem = Project(id: UUID().uuidString, name: name)
        projects.append(newItem)
    }
    func loadProject() {
        AF.request("https://tapuniverse.com/xproject")
            .validate()
            .responseJSON(completionHandler: { response in
                let value = response.value
                if let json = value as? [String: Any],
                   let r = json["result"] as? Int,
                   let project = json["projects"] as? [[String: Any]] {
                    //                    self.result = r
                    for i in 0..<project.count {
                        if let id = project[i]["id"] as? Int,
                           let name = project[i]["name"] as? String{
                            
                            let project = Project(id: "\(id)", name: name)
                            
                            self.projects.append(project)
                        }
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(Projects.projectDidLoadKey), object: nil)
                }
                
            })
        
    }

    
    func deleteData() -> Void {}
    
}


struct ProjectsData: Codable {
    var checkApi = false
    var projectsString: [A]
    
    func projectsToString() {
        
    }
}
