



import UIKit

protocol GalleryViewDelegate: AnyObject {
    func galleryViewSelectImage (_ view: UIImageView)
    func galleryViewChangeImage(_ view: UIImageView)
    func galleryDeselect ()
    func changeSliderWithImage(_ view: UIImageView)
}
class GalleryView: UIView {
    
    var index: Int = 0
    var project: Project?
    var allImage: [UIImageView] = []
    
    
    weak var delegate: GalleryViewDelegate?
    
    private var didLoad = false
    var viewCheck: UIImageView?
    var beginTransform = CGAffineTransform.identity
    var selectedView: UIImageView?
    let buttonDelete = UIButton()
    
    let image = UIImage(named: "minus")
    override func draw(_ rect: CGRect) {
        if didLoad {return}
        buttonDelete.setImage(image, for: .normal)
        buttonDelete.imageView?.contentMode = .scaleAspectFit
        buttonDelete.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        addSubview(buttonDelete)
        
        
        didLoad = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapView(_:))))
        isUserInteractionEnabled = true
    }
    
    func updateOpacity(_ alpha: Double) {
        guard let image = selectedView else {return}
        image.alpha = alpha
        
    }
    func reload() {
        guard let  pr = project else { return }
        for im in allImage {
            im.removeFromSuperview()
        }
        allImage.removeAll()
        for i in 0..<pr.image.count {
            let imageView = UIImageView(image: pr.image[i].image1)
            imageView.layer.frame = pr.image[i].frame
            setUpImageView(imageView)
            
        }
    }
    func addImage(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        let insideRect = bounds.insetBy(dx: 50, dy: 50)
        var width: CGFloat = 100
        var height: CGFloat = 100
        if image.size.width > 0, image.size.height > 0 {
            let imageRatio = image.size.width / image.size.height
            let insideRatio = insideRect.size.width / insideRect.size.width
            
            if imageRatio > insideRatio {
                width = insideRect.width
                height = width / imageRatio
            }else {
                height = insideRect.height
                width = height * imageRatio
            }
            imageView.frame = CGRect(x: insideRect.midX, y: insideRect.midY, width: 0, height: 0).insetBy(dx: -width/2, dy: -height/2)
        }
        
        setUpImageView(imageView)
        
        if let pr = project {
            let newImageId = UUID().uuidString
            let newImageData = ImageData(image1: image, frame: imageView.frame, opacity: 1, imageId: newImageId)
            pr.image.append(newImageData)
        }
        self.delegate?.galleryViewSelectImage(imageView)
        setUpSelectView(imageView)
        showButton(imageView)
    }
    func setUpImageView(_ imageView: UIImageView){
        if imageView.isUserInteractionEnabled {return}
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapView(_:))))
        imageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panView(_:))))
        imageView.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(rotateView(_:))))                                                        
        imageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchView(_:))))
        
        allImage.append(imageView)
        addSubview(imageView)
    }
    @objc private func deleteImage(_ b: UIButton){
        guard let selectedView = selectedView,
              let index = allImage.firstIndex(of: selectedView),
              let pr = project,
              let d = delegate
        else {return}
        selectedView.removeFromSuperview()
        allImage.remove(at: index)
        pr.image.remove(at: index)
        d.galleryDeselect()
        buttonDelete.alpha = 0
    }
    func setUpSelectView(_ view: UIImageView) {
        selectedView = view
        self.bringSubviewToFront(view)
        buttonDelete.alpha = 1
        self.delegate?.changeSliderWithImage(view)
        selectedView = view
    }
    
    func finishGesture(_ view: UIImageView){
        guard let pr = project else {return}
        
        for im in 0..<pr.image.count {
            if view.image == pr.image[im].image1 {
                pr.image[im].frame = view.frame
            }
        }
    }
    
    func changeSlideWithImage(_ view: UIImageView){
    }
    func showButton(_ view: UIImageView) {
        let a = view.transform.a
        let c = view.transform.c
        let scale = CGFloat(sqrt(Double(a*a + c*c)))
        //        print(scale)
        let p = view.convert(CGPoint(x: view.bounds.midX, y: (-20)/scale ), to: self)
        let rect = CGRect(origin: p, size: .zero).insetBy(dx: -10, dy: -10)
        buttonDelete.frame = rect
        bringSubviewToFront(buttonDelete)
    }
    
    
    
    
    
    
    
    
    
    
    @objc func tapView(_ sender: UITapGestureRecognizer){
        guard let d = delegate else {return}
        if  let view = sender.view as? UIImageView {
            switch sender.state {
            case .ended:
                if selectedView != view {
                    d.galleryViewSelectImage(view)
                    selectedView = view
                    self.setUpSelectView(view)
                    showButton(view)
                }
                else {
                    d.galleryDeselect()
                    selectedView = nil
                    buttonDelete.alpha = 0
                }
//                print(view.alpha)
            default:
                print("end")
            }
        }
        else {
            delegate?.galleryDeselect()
            buttonDelete.alpha = 0
            selectedView = nil
        }
        
    }
    @objc func panView(_ sender: UIPanGestureRecognizer){
        guard let view = sender.view as? UIImageView else {return}
        self.setUpSelectView(view)
        switch sender.state {
        case .began:
            beginTransform = view.transform
        case .changed:
            let translation = sender.translation(in: view)
            view.transform = beginTransform.translatedBy(x: translation.x, y: translation.y)
            showButton(view)
            if let d = delegate {
                d.galleryViewSelectImage(view)
            }
        case .ended:
            finishGesture(view)
            print("end")
        default:
            print("end")
        }
    }
    @objc func rotateView(_ sender: UIRotationGestureRecognizer) {
        guard let view = sender.view as? UIImageView else {return}
        self.setUpSelectView(view)
        switch sender.state {
        case .began:
            beginTransform = view.transform
        case .changed:
            view.transform = beginTransform.rotated(by: sender.rotation)
            showButton(view)
            
            if let d = delegate {
                d.galleryViewSelectImage(view)
            }
        case .ended:
            finishGesture(view)
            print("end")
        default:
            print("end")
        }
    }
    
    @objc func pinchView(_ sender: UIPinchGestureRecognizer) {
        guard let view = sender.view as? UIImageView else {return}
        
        self.setUpSelectView(view)
        switch sender.state {
        case .began:
            beginTransform = view.transform
        case .changed:
            view.transform = beginTransform.scaledBy(x: sender.scale, y: sender.scale)
            showButton(view)
            if let d = delegate {
                d.galleryViewChangeImage(view)
            }
        case .ended:
            finishGesture(view)
            print("end")
        default:
            print("end")
        }
    }
}
