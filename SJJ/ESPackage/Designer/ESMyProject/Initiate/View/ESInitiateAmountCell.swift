
import UIKit

protocol ESInitiateAmountCellDelegate: ESInitiateBaseCellDelegate {
    func changePayAmount(index: Int, section: Int, amount: String)
    func canEdit(index: Int, section: Int) -> (Bool, String?)
}

class ESInitiateAmountCell: ESInitiateBaseCell, UITextFieldDelegate {
    
    @IBOutlet weak var payAmountTextField: UITextField!
    private var index: Int = 0
    private var section: Int = 0
    private var lastAmount: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        payAmountTextField.delegate = self
        payAmountTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
    }

    override func updateCell(index: Int, section: Int) {
        self.index = index
        self.section = section
        
        let dele = delegate as? ESInitiateAmountCellDelegate
        let edit = dele?.canEdit(index: index, section: section)
        payAmountTextField.isEnabled = (edit?.0)!
        payAmountTextField.text = edit?.1
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let dele = delegate as? ESInitiateAmountCellDelegate
        dele?.changePayAmount(index: index, section: section, amount: textField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, text.contains("."), string == "." {
            return false
        }
        return true
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        let amount = Double(textField.text ?? "") ?? 0.00
        if amount < 10000000.00 {
            lastAmount = textField.text
            return
        }
        textField.text = lastAmount
    }
}
