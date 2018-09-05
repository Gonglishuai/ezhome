//
//  ESEvaluateFirthCollectionViewCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/1/31.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESEvaluateFirthCollectionViewCellProtocol:NSObjectProtocol {
    func getImage(index: Int) -> (UIImage?, Bool)
    func addImage()
}

class ESEvaluateFirthCollectionViewCell: UICollectionViewCell {

    var cellDelegate:ESEvaluateFirthCollectionViewCellProtocol?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageView.layer.addSublayer(borderLayer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMethod(tap:)))
        imageView.addGestureRecognizer(tap)
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }

    func updateCell(index: Int) {
        if let (image, border) = cellDelegate?.getImage(index: index) {
            imageView.image = image
//            var borerlay: CAShapeLayer?
//            if let layers = imageView.layer.sublayers {
//                for layer in layers {
//                    if layer == borderLayer {
//                        borerlay = (layer as! CAShapeLayer)
//                        break
//                    }
//                }
//            }
//
//            if border {
//                if borerlay == nil {
//                    imageView.layer.addSublayer(borderLayer)
//                }
//            } else {
//                if borerlay != nil {
//                    borerlay!.removeFromSuperlayer()
//                }
//            }
        }
    }

    @objc func tapMethod(tap:UITapGestureRecognizer){
        if let delegate = self.cellDelegate {
            delegate.addImage()
        }
    }
    
    lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        let frame = CGRect(x: 0, y: 0, width: 73.scalValue, height: 73.scalValue)
        layer.path = UIBezierPath(roundedRect: frame, cornerRadius: 3.0).cgPath
        layer.frame = frame
        layer.lineWidth = 0.5
        layer.strokeColor = ESColor.color(sample: .textGray).cgColor
        layer.lineCap = "square"
        layer.lineDashPattern = [NSNumber(value: 2), NSNumber(value: 2)]
        return layer
    }()
}
