
import UIKit

protocol ESInitiateTextInputCellDelegate: ESInitiateBaseCellDelegate {
    func getPlaceholderName(index: Int, section: Int) -> String
    func textInputDidChangeText(text: String)
}

class ESInitiateTextInputCell: ESInitiateBaseCell, UITextViewDelegate {
    
    @IBOutlet weak var textInputView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textInputView.layer.masksToBounds = true;
        textInputView.layer.borderColor = ESColor.color(hexColor: 0xebeced, alpha: 1).cgColor
        textInputView.layer.borderWidth = 0.5
    }
    
    override func updateCell(index: Int, section: Int) {
    
        if let cellDelegate = delegate as? ESInitiateTextInputCellDelegate {
            let title = cellDelegate.getPlaceholderName(index: index, section: section)
            if (!ESStringUtil.isEmpty(title)) {
                placeHolderLabel.text = title
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        placeHolderLabel.isHidden = textView.hasText;
        
        if let cellDelegate = delegate as? ESInitiateTextInputCellDelegate {
            cellDelegate.textInputDidChangeText(text: textView.text)
        }
    }
    
    
}
