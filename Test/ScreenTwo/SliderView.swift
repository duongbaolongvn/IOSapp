import UIKit




protocol SliderViewDelegate: AnyObject {
    func alphaChanged(_ alpha: Double)
}
class SliderView: UIView {
    
    let padding: CGFloat = 20
    let lineWidth: Double = 6
    let radius: Double = 12
    let line = CAGradientLayer()
    let circle = CAShapeLayer()
    let minVale: CGFloat = 0
    let maxValue: CGFloat = 1
    var value: CGFloat = 0.5
    var beginX: CGFloat = 0
    var isInsideView = false
    let startLineColor = UIColor.blue
    let endLineColor: UIColor = UIColor(named: "sliderPink") ?? UIColor.systemPink
    weak var delegate: SliderViewDelegate?
    var didLoad = false
    
    override func draw(_ rect: CGRect) {
        line.cornerRadius = lineWidth/2
        line.startPoint = .init(x: 0, y: 0.5)
        line.endPoint = .init(x: 1, y: 0.5)
        line.frame = CGRect(x: padding, y: self.bounds.maxY/2 - lineWidth/2, width: self.bounds.maxX - 2*padding, height: lineWidth)
        line.colors = [startLineColor.cgColor, endLineColor]
        
        let midX = padding + (bounds.width - 2*padding)*value
        let rect = CGRect(x: midX, y: bounds.height/2, width: 0, height: 0).insetBy(dx: -radius, dy: -radius)
        circle.frame = rect
        circle.path = UIBezierPath(ovalIn: circle.bounds).cgPath
        circle.fillColor = startLineColor.getMiddleGradientColor(endLineColor, percentage: value).cgColor
        circle.strokeColor = UIColor.white.cgColor
        circle.lineWidth = 4
        layer.addSublayer(line)
        layer.addSublayer(circle)
        if didLoad {
            return
        }
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(_:))))
        didLoad = true
    }
    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            isInsideView = circle.frame.insetBy(dx: -20, dy: -20).contains(sender.location(in: self))
            beginX = circle.frame.minX
        }
        if isInsideView && sender.state == .changed {
            let pannedDistance = sender.translation(in: self).x
            var newX = beginX + pannedDistance
            newX = min(newX, bounds.width - padding - 2*radius)
            newX = max(newX, padding)
            circle.frame = CGRect(origin: CGPoint(x: newX, y: circle.frame.minY), size: circle.frame.size)
            circle.removeAllAnimations()
            circle.fillColor = startLineColor.getMiddleGradientColor(endLineColor, percentage: value).cgColor
            value = (newX - padding)/(bounds.width - 2*padding - 2*radius)
            if let d = delegate {
                d.alphaChanged(value)
            }
        }
    }
    
    func changeSliderImageAlpha(_ view: UIImageView) {
        let value = view.alpha
        let circleX = padding + (bounds.width - 2*padding)*value
        circle.frame = CGRect(x: circleX, y: bounds.height/2, width: 0, height: 0).insetBy( dx: -radius, dy: -radius)
    }
}
extension UIColor {
    func getMiddleGradientColor(_ color: UIColor, percentage: CGFloat) -> UIColor{
        let percentage = max(min(percentage, 100), 0)
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
            guard self.getRed(&r2, green: &g1, blue: &b1, alpha: &a1) else {return self}
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else {return self}
            
            
            return UIColor(red: CGFloat(r1 + (r2 - r1)*percentage),
                           green: CGFloat(g1 + (g2 - g1)*percentage),
                           blue: CGFloat(b1 + (b2 - b1)*percentage),
                           alpha: CGFloat(a1 + (a2 - a1)*percentage))
        }
    }
}



