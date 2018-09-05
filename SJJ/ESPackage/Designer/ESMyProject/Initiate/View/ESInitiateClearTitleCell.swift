
import UIKit

protocol ESInitiateClearTitleCellDelegate: ESInitiateBaseCellDelegate {
    func getErpInfo(index: Int, section: Int) -> String
}

class ESInitiateClearTitleCell: ESInitiateBaseCell {

    @IBOutlet weak var erpIdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func updateCell(index: Int, section: Int) {
        if let cellDelegate = delegate as? ESInitiateClearTitleCellDelegate {
            let erpId = cellDelegate.getErpInfo(index: index, section: section)
            if (!ESStringUtil.isEmpty(erpId)) {
                erpIdLabel.text = erpId
            }
        }
    }
}
