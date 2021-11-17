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
                self.container.backButtonPressed()
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
    
    @IBAction func exportButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            let galleryImage = self.container.drawImage()
            let alert = UIAlertController(title: "Export", message: "Export or Share", preferredStyle: .alert)
            let exportGallery = UIAlertAction(title: "Export", style: .default) { _ in
                UIImageWriteToSavedPhotosAlbum(galleryImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            let shareGallery = UIAlertAction(title: "Share", style: .default) { _ in
                let activityViewController = UIActivityViewController(activityItems: [galleryImage], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            }
            alert.addAction(shareGallery)
            alert.addAction(exportGallery)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
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
