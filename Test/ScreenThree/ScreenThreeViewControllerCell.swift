

import UIKit

class ScreenThreeViewControllerCell: UICollectionViewCell {
    override func draw(_ rect: CGRect) {
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 0
        layer.masksToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 2 : 0
        }
    }
    @IBOutlet weak var imageView: UIImageView!
}

