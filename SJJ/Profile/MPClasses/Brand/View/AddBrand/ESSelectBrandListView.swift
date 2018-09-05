//
//  ESSelectBrandListView.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/27.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESSelectBrandListView: UIControl,UITableViewDelegate, UITableViewDataSource {

    var selectTypeBlock:((_ typeIndex:Int)->Void)?//品牌分类
    
    private var tableView: UITableView!
    private var backHud: UIView!
    
    private var dataSource = [String]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        dataSource = ["全部","家具","建材"]
        
        backHud = UIView()
        addSubview(backHud)
        backHud.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        backHud.alpha = 0.3
        backHud.backgroundColor = UIColor.black
        
        tableView = ESUIViewFactory.tableView(.plain)
        
        tableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 300)
        tableView.rowHeight = 50
        
        addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib.init(nibName: "ESSelectBrandsTypeListTableViewCell", bundle: nil), forCellReuseIdentifier: "ESSelectBrandsTypeListTableViewCell")

        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSelectView))
        backHud.addGestureRecognizer(tap)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellModel(data:[String]){
        self.dataSource = data
        tableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 0 )

        if data.count <= 6 {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50 * CGFloat(data.count) )
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 300 )
            })
        }
        
        tableView.reloadData()
    }
    
    @objc func hiddenSelectView(){
        self.removeFromSuperview()
    }
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ESSelectBrandsTypeListTableViewCell", for: indexPath)as!ESSelectBrandsTypeListTableViewCell
        if !dataSource.isEmpty {
            cell.setCellModel(name: dataSource[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let block = selectTypeBlock {
            block(indexPath.row)
        }
        self.hiddenSelectView()
    }
}

