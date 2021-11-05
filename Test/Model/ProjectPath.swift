//
//  ProjectPath.swift
//  Test
//
//  Created by Duong Bao Long on 11/2/21.
//

import UIKit

struct ProjectPath: Codable {
    //    var id: String
    var imagePath: [imageBase]
    
    func projectToString(_ pr: ProjectPath) -> String{
        let encoder = JSONEncoder()
        let data = try? encoder.encode(pr)
        let string = String(data: data!, encoding: .utf8)!
        return string
    }
    
    
}
struct imageBase: Codable {
    var url: String
    var frame1 = CGRect.zero
}
