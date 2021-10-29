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
    
    var image: [ImageData] = []
    
    var busy = false
    
    init(id: String, name: String){
        self.id = id
        self.name = name
    }
    func getDetail(_ completion: (() -> Void)? = nil ) {
        
        if busy {return}
        busy = true
        image.removeAll()
        
        AF.request("https://tapuniverse.com/xprojectdetail", method: .post, parameters: ["id": id])
            .validate(statusCode: 200 ..< 299)
            .responseJSON(completionHandler: { response in
                let value = response.value
                if let json = value as? [String: Any],
                   let photo = json["photos"] as? [[String: Any]] {
                    
                    var count = 0
                    if photo.count == 0 {self.busy = false}
                    
                    for i in 0..<photo.count {
                        if let url = photo[i]["url"] as? String,
                           let frame = photo[i]["frame"] as? [String: Any],
                           let x = frame["x"] as? CGFloat,
                           let y = frame["y"] as? CGFloat,
                           let width = frame["width"] as? CGFloat,
                           let height = frame["height"] as? CGFloat {
                            let frame = CGRect(x: x, y: y, width: width, height: height)
                            AF.request(url, method: .get)
                                .validate()
                                .responseData { response in
                                    if let data = response.value,
                                       let image1 = UIImage(data: data) {
                                        let imageData = ImageData(image1: image1, frame: frame)
                                        self.image.append(imageData)
                                        if let c = completion {
                                            c()
                                        }
                                    }
                                    
                                    count += 1
                                    if count >= photo.count {
                                        self.busy = false
                                    }
                                }
                            
                            
                        }
                    }
                }
            })
    }
}

class ImageData {
    var image1: UIImage
    var frame = CGRect.zero
    var transform = CGAffineTransform.identity
    
    init(image1: UIImage, frame: CGRect){
        self.image1 = image1
        self.frame = frame
    }
}
