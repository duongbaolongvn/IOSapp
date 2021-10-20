//
//  ProjectID.swift
//  Test
//
//  Created by Duong Bao Long on 10/11/21.
//

import Foundation
import UIKit
import Alamofire

class Project {
    var id: String
    var name: String
    
    let image: [ImageData] = []
    
    init(id: String, name: String){
        self.id = id
        self.name = name
    }
    func getDetail(_ id: String) {
        
        AF.request("https://tapuniverse.com/xprojectdetail", method: .post, parameters: ["id": id])
            .validate(statusCode: 200 ..< 299)
            .responseJSON(completionHandler: { response in
                if let value = response.value{
                    
                }
            })
        
        
    }
}

class ImageData {
    var image1: UIImage?
    var frame = CGRect.zero
    
}
