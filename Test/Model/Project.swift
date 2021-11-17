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
    func rerange (image: [ImageData], fromIndex: Int)  {
        var arr = image
        let element = arr.remove(at: fromIndex)
        arr.append(element)
    }
    func saveData(){
        var savedObject = A(id: id, name: name, images: [ImageBase?](repeating: nil, count: image.count))
        for im in 0..<image.count {
            let imageId = image[im].imageId
            let imageBase = image[im].imageToObject(imageId)
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
        let decoder = JSONDecoder()
        if let data = stringData.data(using: .utf8),
           let sameA = try? decoder.decode(A.self, from: data) {
            
            image.removeAll()
            for im in 0..<sameA.images.count {
                if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
                   let imageIdLoad = sameA.images[im]?.imageIdData {
                    let fileUrl = url.appendingPathComponent("image\(imageIdLoad)")
                    if let imageFromFile = UIImage(contentsOfFile: fileUrl.path){
                        let imageData = ImageData(image1: imageFromFile, frame: sameA.images[im]!.frame1, opacity: sameA.images[im]!.opacity, imageId: imageIdLoad)

                        self.image.append(imageData)
                    }
                }
            }
        }
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
                    self.image.removeAll()
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
                                        let imageData = ImageData(image1: image1, frame: frame, opacity: 1, imageId: UUID().uuidString)
                                        self.image.append(imageData)
                                        if let c = completion {
                                            c()
                                        }
                                    }
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
    var opacity: CGFloat
    var imageId: String
    init(image1: UIImage, frame: CGRect, opacity: CGFloat, imageId: String){
        self.image1 = image1
        self.frame = frame
        self.opacity = opacity
        self.imageId = imageId
    }
    
    func changeAlpha(_ alpha: CGFloat) {
        self.opacity = alpha
    }
    func imageToObject(_ imageId: String) -> ImageBase {
        
        var object = ImageBase(url: "", frame1: frame, opacity: opacity, imageIdData: imageId)
        if let data = image1.jpegData(compressionQuality: 1),
           let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            let fileUrl = url.appendingPathComponent("image\(imageId).png")
            do {
                try data.write(to: fileUrl)
                object = ImageBase(url: fileUrl.path, frame1: frame, opacity: opacity, imageIdData: imageId )
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
    var opacity: CGFloat
    var imageIdData: String
}
