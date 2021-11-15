import UIKit

class ViewGalleryController: UIViewController, GalleryViewDelegate, UINavigationControllerDelegate, SliderViewDelegate{
    
    
    var project: Project?
    
    @IBOutlet weak var sliderView: SliderView!
    @IBOutlet weak var container: GalleryView!
    @IBOutlet weak var editView: EditView!
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container.project = project
        
        sliderView.delegate = self
        sliderView.isHidden = true
        container.delegate = self
        guard let  pr = project else {return}
        pr.getDetail({
            self.container.reload()
            self.editView.hide()
        }, pr.id)
    }
 
    @IBAction func backButton(_ sender: UIButton) {
        guard let pr = project else {return}
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Save Project", message: "Save changed project?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Don't save", style: .cancel) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            let saveAction = UIAlertAction(title: "Save project", style: .default) { _ in
                pr.saveData()
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            self.present(alert, animated: true, completion: nil)
        }
       
    }
    @IBAction func tapToCameraRoll(_ sender: UIButton) {
        guard let screen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScreenThreeViewController") as? ScreenThreeViewController else { return }
        screen.delegate = self
        present(screen, animated: true, completion: nil)
    }
        
    func galleryViewSelectImage(_ view: UIImageView) {
        sliderView.isHidden = false
        editView.show(view)
    }
    
    func galleryDeselect() {
        editView.hide()
        sliderView.isHidden = true
    }
    func galleryViewChangeImage(_ view: UIImageView) {
        editView.show(view)
        sliderView.isHidden = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let possibleImage = info[.originalImage] as? UIImage else {return}
        container.addImage(possibleImage)
    }
    func alphaChanged(_ alpha: Double) {
        container.updateOpacity(alpha)
    }
    func changeSliderWithImage(_ view: UIImageView) {
        sliderView.changeSliderImageAlpha(view)
    }
    
}
extension ViewGalleryController: CustomPhotoPickerDelegate {
    func imageDidSelected(_ image: UIImage) {
        container.addImage(image)
    }
}
