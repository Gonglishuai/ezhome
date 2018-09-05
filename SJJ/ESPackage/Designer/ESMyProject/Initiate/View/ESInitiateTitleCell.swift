
import UIKit

protocol ESInitiateTitleCellDelegate: ESInitiateBaseCellDelegate {
    func getTitleName(index: Int, section: Int) -> String
}

class ESInitiateTitleCell: ESInitiateBaseCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func updateCell(index: Int, section: Int) {
        if let cellDelegate = delegate as? ESInitiateTitleCellDelegate {
            let title = cellDelegate.getTitleName(index: index, section: section)
            if (!ESStringUtil.isEmpty(title)) {
                titleLabel.text = title
            }
        }
    }
}
