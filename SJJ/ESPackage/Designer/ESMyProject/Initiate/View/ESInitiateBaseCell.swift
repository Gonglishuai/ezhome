
import UIKit

protocol ESInitiateBaseCellDelegate: NSObjectProtocol {
    
}

class ESInitiateBaseCell: UITableViewCell {

    weak var delegate: ESInitiateBaseCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
    }

    func updateCell(index: Int, section: Int) {
        
    }
}
