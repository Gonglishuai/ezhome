
import UIKit

protocol ESInitiateCouponCellDelegate: ESInitiateBaseCellDelegate {
    func getCouponInfos(index: Int, section: Int) -> [[String: Any]]
    func getReturnCashInfos(index: Int, section: Int) -> [[String: Any]]
}

class ESInitiateCouponCell: ESInitiateBaseCell {
    
    @IBOutlet weak var couponsBackgroundView: UIView!
    @IBOutlet weak var couponsBackgroundViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var returnCashBackgroundView: UIView!
    @IBOutlet weak var returnCashBackgroundViewHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.couponsBackgroundViewConstraint.constant = 14
        self.returnCashBackgroundViewHeightConstraint.constant = 14
    }
    
    override func updateCell(index: Int, section: Int) {
        
        self.couponsBackgroundViewConstraint.constant = 14
        self.returnCashBackgroundViewHeightConstraint.constant = 14
        
        if let cellDelegate = delegate as? ESInitiateCouponCellDelegate {
            let coupons = cellDelegate.getCouponInfos(index: index, section: section)
            var couponLabelX :CGFloat = 0
            var couponLabelY :CGFloat = 0
            let labelHeight :CGFloat = 15
            let labelWidSpace :CGFloat = 8
            let labelHeiSpace :CGFloat = 8
            let maxWidth :CGFloat = ScreenWidth - 68
            
            /// 优惠
            for view in self.couponsBackgroundView.subviews {
                view.removeFromSuperview()
            }
            for promotion in coupons {
                let proModel :ESPackagePromotion = promotion["promotion"] as! ESPackagePromotion
                let labelWidth :CGFloat = CGFloat((promotion["width"] as! NSString).floatValue)

                if (couponLabelX + labelWidth > maxWidth) {
                    couponLabelX = 0
                    couponLabelY = couponLabelY + labelHeiSpace + labelHeight
                }
                
                let label = UILabel()
                label.font = ESFont.font(name: .medium, size: 10)
                label.textColor = ESColor.color(hexColor: 0xdb4f44, alpha: 1)
                label.text = " " + proModel.promotionName! + " "
                label.layer.masksToBounds = true
                label.layer.cornerRadius = 2.0
                label.layer.borderWidth = 0.5
                label.layer.borderColor = ESColor.color(hexColor: 0xdb4f44, alpha: 1).cgColor
                label.frame = CGRect(x: couponLabelX, y: couponLabelY, width: labelWidth, height: labelHeight)
                self.couponsBackgroundView .addSubview(label)
                
                couponLabelX = couponLabelX + labelWidSpace + labelWidth
            }
            self.couponsBackgroundViewConstraint.constant = couponLabelY + labelHeight
            
            /// 返现
            for view in self.returnCashBackgroundView.subviews {
                view.removeFromSuperview()
            }
            let returnCash = cellDelegate.getReturnCashInfos(index: index, section: section)
            var returnLabelX :CGFloat = 0
            var returnLabelY :CGFloat = 0
            for promotion in returnCash {
                let proModel :ESPackagePromotion = promotion["promotion"] as! ESPackagePromotion
                let labelWidth :CGFloat = CGFloat((promotion["width"] as! NSString).floatValue)
                
                if (returnLabelX + labelWidth > maxWidth) {
                    returnLabelX = 0
                    returnLabelY = returnLabelY + labelHeiSpace + labelHeight
                }
                
                let label = UILabel()
                label.font = ESFont.font(name: .medium, size: 10)
                label.textColor = ESColor.color(hexColor: 0xdb4f44, alpha: 1)
                label.text = " " + proModel.promotionName! + " "
                label.layer.masksToBounds = true
                label.layer.cornerRadius = 2.0
                label.layer.borderWidth = 0.5
                label.layer.borderColor = ESColor.color(hexColor: 0xdb4f44, alpha: 1).cgColor
                label.frame = CGRect(x: returnLabelX, y: returnLabelY, width: labelWidth, height: labelHeight)
                self.returnCashBackgroundView.addSubview(label)
                
                returnLabelX = returnLabelX + labelWidSpace + labelWidth
            }
            self.returnCashBackgroundViewHeightConstraint.constant = returnLabelY + labelHeight
        }
    }
}
