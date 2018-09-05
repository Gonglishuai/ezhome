
import UIKit

protocol ESInitiatePaymentViewDelegate: ESTableViewProtocol {
    func getCellIds() -> Array<String>
    func getDequeueReusableCell(indexPath: IndexPath) -> String
}

class ESInitiatePaymentView: UIView, UITableViewDelegate, UITableViewDataSource{

    private weak var delegate: ESInitiatePaymentViewDelegate?
    var tableView: UITableView!
    
    init(delegate: ESInitiatePaymentViewDelegate?, controller: UIViewController) {
        super.init(frame: CGRect.zero)
        self.delegate = delegate
        setUpTableView(controller: controller)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpTableView(controller: UIViewController) {
        let tabVc = UITableViewController(style: .plain)
        controller.addChildViewController(tabVc)
        tableView = tabVc.tableView
        tableView.backgroundColor = ESColor.color(sample: .backgroundView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        self.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(self.snp.top)
            make.bottom.equalTo(self.snp.bottom)
        }
        
        let cellIds = delegate?.getCellIds() ?? []
        for cellId in cellIds {
            tableView.register(UINib.init(nibName: cellId, bundle: ESPackageAsserts.hostBundle), forCellReuseIdentifier: cellId)
        }
    }
    
    func refreshMainView() {
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate?.getSectionNum!() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.getItemNum(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = delegate?.getDequeueReusableCell(indexPath: indexPath) ?? ""
        if cellId.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! ESInitiateBaseCell
            cell.delegate = self.delegate as? ESInitiateBaseCellDelegate
            cell.updateCell(index: indexPath.row, section: indexPath.section)
            return cell
        }
        
        return UITableViewCell();
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0
        }
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            return nil;
        }
        
        let view = UIView()
        view.backgroundColor = ESColor.color(sample: .backgroundView)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.endEditing(true)
        
        delegate?.selectItem!(index: indexPath.row, section: indexPath.section)
    }
}
