
import UIKit

public class ESInitiatePaymentViewController: ESBasicViewController, ESInitiatePaymentViewDelegate, ESInitiateClearTitleCellDelegate, ESInitiatePayTypeCellDelegate, ESInitiateAmountCellDelegate, ESInitiateTitleCellDelegate, ESInitiateCouponCellDelegate, ESInitiateTextInputCellDelegate {
    
    private var contractInfo = ESAgreementModel()
    private var complete: (() -> Void)!
    
    private var assetId = ""
    private var erpId = ""
    private var couponList = [[String: Any]]()
    private var returnList = [[String: Any]]()
    private var showContract = false
    private var orderType: ESPkgOrderType = .NONE
    private var payment: ESPackagePayment = ESPackagePayment()
    private var payTypes = [ESPkgOrderType]()
    
    init(_ assetId: String,
         _ erpId: String,
         _ promotionList: [ESPackagePromotion],
         _ showContract: Bool,
         _ contractInfo: ESAgreementModel,
         _ payTypes: [ESPkgOrderType],
         complete: @escaping () -> Void) {
        
        super.init(nibName: nil, bundle: nil)
        self.assetId = assetId
        self.erpId = erpId
        self.showContract = showContract
        self.contractInfo = contractInfo
        self.complete = complete
        self.payTypes = payTypes
        
        let returnListData = promotionList.filter{$0.rewardType != nil && $0.rewardType! == 1}
        returnList = ESInitiatePaymentViewModel.updatePromotions(promotions: returnListData)
        let couponListData = promotionList.filter{$0.rewardType != nil && $0.rewardType! == 2}
        couponList = ESInitiatePaymentViewModel.updatePromotions(promotions: couponListData)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        initData()
        
        setupNavigationTitleWithBack(title: "发起收款")
        view.addSubview(mainView)
        view.addSubview(confirmBtn)
        view.addSubview(alertView)
        mainView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(confirmBtn.snp.top)
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            }else {
                make.top.equalTo(self.view.snp.top)
            }
        }
        confirmBtn.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(49.scalValue)
        }
        alertView.snp.makeConstraints { (make) in
            make.bottom.equalTo(confirmBtn.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(38.scalValue)
        }
        alertLabel.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalToSuperview()
        }
    }
    
    func initData() {
        _items = ESInitiatePaymentViewModel.getInitiateItems()
    }
    
    // MARK: - ESInitiatePaymentViewDelegate
    func getItemNum(section: Int) -> Int {
        if section < _items.count {
            let rowItems = _items[section]
            return rowItems.count
            
        }
        return 0
    }

    func getSectionNum() -> Int {
        return _items.count
    }
    
    func getCellIds() -> Array<String> {
        let array = [
            "ESInitiateClearTitleCell",
            "ESInitiatePayTypeCell",
            "ESInitiateAmountCell",
            "ESInitiateTitleCell",
            "ESInitiateCouponCell",
            "ESInitiateTextInputCell",
            "ESInitiateContractCell"]
        return array
    }
    
    func getTypes() -> [ESPkgOrderType] {
        return self.payTypes
    }
    
    func getDequeueReusableCell(indexPath: IndexPath) -> String {
        return ESInitiatePaymentViewModel.getItemValue(key: ESInitiatePaymentViewModel.CELL_ID, index: indexPath.row, section: indexPath.section, items: _items);
    }
    
    func selectItem(index: Int, section: Int) {
        let itemId = ESInitiatePaymentViewModel.getItemValue(key: ESInitiatePaymentViewModel.KEY, index: index, section: section, items: _items);
        switch itemId {
        case "payType":
            DispatchQueue.main.async {
                self.showChooseTypeSheet()
            }
            break
        case "contact":
            let vc = ESAgreementViewController()
            vc.upload = contractInfo
            vc.AgreeAgreementBlock = {
                DispatchQueue.main.async {
                    self.showContract = false
                    self.showContractInfo(false)
                    self.mainView.refreshMainView()
                    if let dvc = ESPackageManager.refreshDesProjectDetail(self.navigationController) {
                        dvc.requestData()
                    }
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        default: break;
        }
    }
    
    func showChooseTypeSheet() {
        let alertController = UIAlertController(title: "费用类型",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let list = getTypes()
        for type in list {
            let action = UIAlertAction(title: type.rawValue.key, style: .default, handler: {
                action in
                self.selectedType(type)
            })
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func selectedType(_ type: ESPkgOrderType) {
        showContractInfo(type == .FIRST_FEE && showContract)
        
        if type == .FIRST_FEE && showContract {
            ESProgressHUD.showText(in: self.view, text: "发起装修款首款前需设置合同")
            orderType = .NONE
            _payType = "请选择费用类型"
            mainView.refreshMainView()
            return
        }
        
        orderType = type
        _payType = type.rawValue.key

        /// 选择类型后 获取应支付费用
        getPayment()
    }
    
    func showContractInfo(_ show: Bool) {
        if let item = _items.last,
            let cid = item[0]["cellId"] {
            if show {
                if cid != "ESInitiateContractCell" {
                    var thirdItems = [[String: String]]()
                    var contactItems = [String: String]()
                    contactItems.updateValue("contact", forKey: "key")
                    contactItems.updateValue("ESInitiateContractCell", forKey: "cellId")
                    thirdItems.append(contactItems)
                    _items.append(thirdItems)
                }
            } else {
                if cid == "ESInitiateContractCell" {
                    _items.remove(at: _items.endIndex - 1)
                }
            }
        }
    }
    
    private func getPayment() {
        let taype = String(orderType.rawValue.value)
        ESProgressHUD.show(in: self.view)
        ESInitiatePaymentViewDataManager.getPayment(assetId, taype, success: { (paymentModel) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                self.payment = paymentModel
                self.check()
                self.mainView.refreshMainView()
                if self.orderType == .FIRST_FEE {
                    self.showAlert()
                } else {
                    self.alertView.alpha = 0.0
                }
            }
        }) { (msg) in
            DispatchQueue.main.async {
                ESProgressHUD.hide(for: self.view)
                ESProgressHUD.showText(in: self.view, text: msg)
            }
        }
    }
    
    // MARK: - ESInitiateClearTitleCellDelegate
    func getErpInfo(index: Int, section: Int) -> String { // erp编号
        return erpId
    }

    // MARK: - ESInitiatePayTypeCellDelegate
    func getPayType(index: Int, section: Int) -> String { // 支付类型
        return _payType
    }
    
    // MARK: - ESInitiateAmountCellDelegate
    func changePayAmount(index: Int, section: Int, amount: String) { // 支付金额
        payment.amount = Double(amount) ?? 0.0
        check()
    }
    
    func canEdit(index: Int, section: Int) -> (Bool, String?) {
        let canEdit = payment.editStatus ?? true
        var amountStr: String?
        if let amount = payment.amount, amount > 0 {
            amountStr = String(amount)
        }
        let editInfo = (canEdit, amountStr)
        return editInfo
    }
    
    // MARK: - ESInitiateTitleCellDelegate
    func getTitleName(index: Int, section: Int) -> String { // 获取标题
        return index == 0 ? "已选优惠" : "备注说明"
    }
    
    // MARK: - ESInitiateCouponCellDelegate
    func getCouponInfos(index: Int, section: Int) -> [[String: Any]] {
        return couponList
    }
    
    func getReturnCashInfos(index: Int, section: Int) -> [[String: Any]] {
        return returnList
    }
    
    // MARK: - ESInitiateTextInputCellDelegate
    func getPlaceholderName(index: Int, section: Int) -> String {
        return ""
    }
    
    func textInputDidChangeText(text: String) {
        _remarks = text;
    }
    
    private func showAlert() {
        let amount = payment.amount ?? 0.0
        let discount = (payment.discountAmount ?? 0.0) + (payment.cashBackAmount ?? 0.0)
        let amountStr = String(format: "%.2f", amount)
        let discountStr = String(format: "%.2f", discount)
        self.alertLabel.text = "共发起收款 ¥\(amountStr)，共优惠 ¥\(discountStr)"
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
            self.alertView.alpha = 1.0
        }, completion: nil)
        self.confirmBtn.isEnabled = true
    }
    
    private func check() {
        if let amount = payment.amount, amount > 0, orderType != .NONE {
            confirmBtn.isEnabled = true
        } else {
            confirmBtn.isEnabled = false
        }
    }
    
    @objc func confirm() {
        if let amount = payment.amount, amount > 0, orderType != .NONE {
            let type = String(orderType.rawValue.value)
            ESProgressHUD.show(in: self.view)
            ESInitiatePaymentViewDataManager.orderCreate(assetId, String(amount), type, _remarks, success: {
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: "发起收款成功!")
                    for vc in (self.navigationController?.viewControllers.reversed())! {
                        if let dvc = vc as? ESDesProjectDetailController {
                            dvc.requestData()
                            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5) {
                                DispatchQueue.main.async {
                                    self.navigationController?.popToViewController(vc, animated: true)
                                }
                            }
                            break
                        }
                    }
                }
            }, failure: { (msg) in
                DispatchQueue.main.async {
                    ESProgressHUD.hide(for: self.view)
                    ESProgressHUD.showText(in: self.view, text: msg)
                }
            })
        }
        
    }
    
    // MARK: - Property
    private lazy var mainView: ESInitiatePaymentView = {
        let view = ESInitiatePaymentView(delegate: self, controller:self)
        return view
    }()
    
    private var _items: Array<Array<[String: String]>> = []
    
    private var _payType: String = "请选择费用类型"
    private var _remarks: String = ""
    private lazy var confirmBtn: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(ESColor.getImage(color: ESColor.color(sample: .buttonBlue)), for: .normal)
        btn.setBackgroundImage(ESColor.getImage(color: ESColor.color(sample: .separatorLine)), for: .disabled)
        btn.setTitle("确定", for: .normal)
        btn.isEnabled = false
        btn.titleLabel?.font = ESFont.font(name: .regular, size: 16.0)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(ESInitiatePaymentViewController.confirm), for: .touchUpInside)
        return btn
    }()
    
    private lazy var alertView: UIView = {
        let view = UIView()
        view.backgroundColor = ESColor.color(hexColor: 0xFFEAC9, alpha: 1.0)
        view.alpha = 0.0
        view.addSubview(alertLabel)
        return view
    }()
    private lazy var alertLabel: UILabel = {
        let label = UILabel()
        label.textColor = ESColor.color(hexColor: 0xFF9A02, alpha: 1.0)
        label.font = ESFont.font(name: .medium, size: 13.0)
        label.textAlignment = .center
        return label
    }()
}
