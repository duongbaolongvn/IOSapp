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
    var didDownloadImage = false
    
    init(id: String, name: String){
        self.id = id
        self.name = name
    }
    func saveData(){
        var savedObject = A(id: id, name: name, images: [ImageBase?](repeating: nil, count: image.count))
        for im in 0..<image.count {
            let imageBase = image[im].imageToObject(im)
            savedObject.images[im] = imageBase
        }
        let encoder = JSONEncoder()
        if let dataOutPut = try? encoder.encode(savedObject),
           let string = String(data: dataOutPut, encoding: .utf8){
            UserDefaults.standard.set(string, forKey: "project\(id)")
        }
    }
    func loadData(_ id: String) -> Bool {
        guard let stringData = UserDefaults.standard.string(forKey: "project\(id)") else {
            return false
        }
//        if stringData == nil {
//            didDownloadImage = false
//            return didDownloadImage
//        }
        let decoder = JSONDecoder()
        if let data = stringData.data(using: .utf8),
           let sameA = try? decoder.decode(A.self, from: data){
            for im in 0..<sameA.images.count{
                if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
                    let fileUrl = url.appendingPathComponent("image\(im)")
                    if let imageFromFile = UIImage(contentsOfFile: fileUrl.path){
                        let imageData = ImageData(image1: imageFromFile, frame: sameA.images[im]!.frame1)
                        self.image.append(imageData)
                    }
                }
            }
        }
//        didDownloadImage = true
//        return didDownloadImage
        return true
    }
    func getDetail(_ completion: (() -> Void)? = nil, _ id: String ) {
        if loadData(id) {
            if let p = completion {
                p()
            }
            return
        }
        AF.request("https://tapuniverse.com/xprojectdetail", method: .post, parameters: ["id": id])
            .validate(statusCode: 200 ..< 299)
            .responseJSON(completionHandler: { response in
                let value = response.value
                if let json = value as? [String: Any],
                   let photo = json["photos"] as? [[String: Any]] {
                    
                    //                        var count = 0
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
                                            print(self.image.count)
                                        }
                                    }
                                    
                                    //                                        count += 1
                                    //                                        if count >= photo.count {
                                    //                                            self.busy = false
                                    //                                        }
                                }
                        }
                    }
                }
            })
        
    }
    
}
class ImageData{
    var image1: UIImage
    var frame = CGRect.zero
    var transform = CGAffineTransform.identity
    
    init(image1: UIImage, frame: CGRect){
        self.image1 = image1
        self.frame = frame
    }
    
    func imageToObject(_ number: Int) -> ImageBase {
        
        var object = ImageBase(url: "", frame1: CGRect.zero)
        if let data = image1.jpegData(compressionQuality: 1),
           let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            let fileUrl = url.appendingPathComponent("image\(number).png")
            do {
                try data.write(to: fileUrl)
                print("ok")
                object = ImageBase(url: fileUrl.path, frame1: frame)
                return object
            } catch {
                print(error.localizedDescription)
            }
            
        }
        return object
    }
}


struct A: Codable {
    var id: String
    var name: String
    var images: [ImageBase?]
}

struct ImageBase: Codable {
    var url: String
    var frame1 = CGRect.zero
}
