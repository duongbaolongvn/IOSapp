import UIKit

class ViewGalleryController: UIViewController {
    
    var project: Project?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let  pr = project else {
            return
        }
        print("\(pr.name), \(pr.id) ")
    }

}
