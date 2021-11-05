import UIKit

class ViewGalleryController: UIViewController, GalleryViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    var project: Project?
    
    @IBOutlet weak var container: GalleryView!
    @IBOutlet weak var editView: EditView!
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container.project = project
        container.delegate = self
        guard let  pr = project else {return}
        pr.getDetail({
            self.container.reload()
            self.editView.hide()
        }, pr.id)
    }
 
    @IBAction func backButton(_ sender: UIButton) {
        guard let navigation = navigationController else {return}
        guard let pr = project else {return}
        pr.saveData()
        navigation.popViewController(animated: true)
    }
    @IBAction func tapToCameraRoll(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: false, completion: nil)
        }
        
    }
    func galleryViewSelectImage(_ view: UIImageView) {
        editView.show(view)
    }
    
    func galleryDeselect() {
        editView.hide()
    }
    func galleryViewChangeImage(_ view: UIImageView) {
        editView.show(view)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let possibleImage = info[.originalImage] as? UIImage else {return}
        container.addImage(possibleImage)
    }
    
}
