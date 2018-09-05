
import UIKit

class ESInitiatePaymentViewModel: ESViewModel {

    static let KEY = "key"
    static let CELL_ID = "cellId"

    static func getInitiateItems() -> Array<Array<[String: String]>>  {
        
        var items = Array<Array<[String: String]>>()
        
        var firstItems = [[String: String]]()
        var erpItems = [String: String]()
        erpItems.updateValue("erpId", forKey: KEY)
        erpItems.updateValue("ESInitiateClearTitleCell", forKey: CELL_ID)
        firstItems.append(erpItems)
        
        var payTypeItems = [String: String]()
        payTypeItems.updateValue("payType", forKey: KEY)
        payTypeItems.updateValue("ESInitiatePayTypeCell", forKey: CELL_ID)
        firstItems.append(payTypeItems)
        
        var payAmountItems = [String: String]()
        payAmountItems.updateValue("payAmount", forKey: KEY)
        payAmountItems.updateValue("ESInitiateAmountCell", forKey: CELL_ID)
        firstItems.append(payAmountItems)
        items.append(firstItems);
        
        var secondItems = [[String: String]]()
        var couponTitleItems = [String: String]()
        couponTitleItems.updateValue("couponTitle", forKey: KEY)
        couponTitleItems.updateValue("ESInitiateTitleCell", forKey: CELL_ID)
        secondItems.append(couponTitleItems)
        
        var couponItems = [String: String]()
        couponItems.updateValue("coupon", forKey: KEY)
        couponItems.updateValue("ESInitiateCouponCell", forKey: CELL_ID)
        secondItems.append(couponItems)
        
        var textInputTitleItems = [String: String]()
        textInputTitleItems.updateValue("textInputTitle", forKey: KEY)
        textInputTitleItems.updateValue("ESInitiateTitleCell", forKey: CELL_ID)
        secondItems.append(textInputTitleItems)
        
        var textInputItems = [String: String]()
        textInputItems.updateValue("textInput", forKey: KEY)
        textInputItems.updateValue("ESInitiateTextInputCell", forKey: CELL_ID)
        secondItems.append(textInputItems)
        items.append(secondItems);
        
//        if hasContract {
//            var thirdItems = [[String: String]]()
//            var contactItems = [String: String]()
//            contactItems.updateValue("contact", forKey: KEY)
//            contactItems.updateValue("ESInitiateContractCell", forKey: CELL_ID)
//            thirdItems.append(contactItems)
//            items.append(thirdItems)
//        }
        
        return items;
    }
    
    static func getItemValue(key: String, index: Int, section: Int, items: Array<Array<[String: String]>>) -> String  {
        if section < items.count {
            let rowItems = items[section]
            if index < rowItems.count {
                let rowDict = rowItems[index]
                return rowDict[key] ?? ""
            }
        }
        return ""
    }
    
    static func updatePromotions(promotions: [ESPackagePromotion]) -> [[String: Any]]  {
        var newPromotions = [[String : Any]]()
        for promotion in promotions {
            let width = getStrWidthFor(str: promotion.promotionName! as NSString, height: 15);
            var promotionDict = [String: Any]();
            promotionDict.updateValue(String.init(format:"%.2f", width), forKey: "width")
            promotionDict.updateValue(promotion, forKey: "promotion")
            newPromotions.append(promotionDict);
        }
        return newPromotions
    }
    
    static func getStrWidthFor(str: NSString, height: CGFloat) -> CGFloat {
        if (ESStringUtil.isEmpty(str as String)) {
            return 0;
        }
        /// 需与ESInitiateCouponCell中优惠券label的funt一样
        let font = ESFont.font(name: .medium, size: 10)
        let rect = String.init(format:" %@ ", str).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return rect.width
    }
    
//    CGRect valueRect = [self.value boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 106 - 20, MAXFLOAT)
//    options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
//    attributes:@{NSFontAttributeName : valueFont}
//    context:nil];
//    self.valueSize = valueRect.size;
}
