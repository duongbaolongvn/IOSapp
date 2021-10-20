//
//  ProjectTableViewCell.swift
//  Test
//
//  Created by Duong Bao Long on 10/13/21.
//

import UIKit

protocol ProjectTableViewCellDelegate: AnyObject {
    func cellDelete(_ cell: ProjectTableViewCell)
    func cellTap(_ cell: ProjectTableViewCell)
}

class ProjectTableViewCell: UITableViewCell{
    
    
    @IBOutlet weak var textName: UILabel!
    @IBOutlet weak var trallingSpace: NSLayoutConstraint!
    
    weak var delegate: ProjectTableViewCellDelegate?
    
    var didLoad = false
    var xBegin: CGFloat = 0
    var didAction = false
    override func draw(_ rect: CGRect) {
        if didLoad {
            return
        }
        didLoad = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
        
        let tabGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.addGestureRecognizer(tabGestureRecognizer)
    }
    
    
    @objc private func panAction(_ sender: UIPanGestureRecognizer){
//        print("did Action")
        guard sender.view != nil else {return}
        switch sender.state{
        case .began:
            xBegin = trallingSpace.constant
        case .changed:
            let translation = sender.translation(in: self)
            trallingSpace.constant = xBegin - translation.x
        case .ended:
            didAction = !didAction
            if didAction {
                trallingSpace.constant = 0
            }else {
                if trallingSpace.constant < 50 {
                    trallingSpace.constant = 0
                }else{
                    trallingSpace.constant = 50
                }
            }
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        default:
            print("done")
        }
    }
    
    @objc private func tapAction(_ sender: UITapGestureRecognizer) {
        guard sender.view != nil else {return}
        self.delegate?.cellTap(self)
    }
    
    
    @IBAction func deletePressed(_ sender: Any) {
        print("delete")
        if let d = delegate {
            d.cellDelete(self)
        }
    }
    
}
