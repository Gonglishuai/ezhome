
import UIKit

protocol ESInitiatePayTypeCellDelegate: ESInitiateBaseCellDelegate {
    func getPayType(index: Int, section: Int) -> String
}

class ESInitiatePayTypeCell: ESInitiateBaseCell {

    @IBOutlet weak var payTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func updateCell(index: Int, section: Int) {
        if let cellDelegate = delegate as? ESInitiatePayTypeCellDelegate {
            let payTypeStr = cellDelegate.getPayType(index: index, section: section)
            if (!ESStringUtil.isEmpty(payTypeStr)) {
                payTypeLabel.text = payTypeStr
            }
        }
    }
}
