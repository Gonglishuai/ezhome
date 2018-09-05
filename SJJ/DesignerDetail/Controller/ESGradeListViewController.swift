//
//  ESGradeListViewController.swift
//  EZHome
//
//  Created by shiyawei on 1/8/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//业主评价
import UIKit

class ESGradeListViewController: ESBasicViewController,UITableViewDelegate,UITableViewDataSource {

    var designId = String()
    var offset = 1
    var limit = 20
    var model:ESGradeModel!
    var CommentInfos = Array<CommentInfoRespBean>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        self.navigationItem.title = "业主评价"
        
        setupNavigationBarBack()
        
        loadData(isLoadMore: false)
        
        self.view.addSubview(self.tableView)
        
        
    }
    
    //    MARK:UITableViewDelegate,UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else {
            if self.model != nil {
                return self.CommentInfos.count
            }
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let data = self.model {
                return ESGradeStarCell.getHeight(model:data)
            }
            return 150
        }else {
            return ESGradeMsgTableViewCell.getHeight(model: self.CommentInfos[indexPath.row])
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ESGradeStarCell", for: indexPath) as! ESGradeStarCell
            if self.model != nil{
                cell.analysisUserModel(model:self.model.data!)
            }
            
            return cell
        }else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "ESGradeMsgTableViewCell", for: indexPath) as! ESGradeMsgTableViewCell
            if self.model != nil{
                
                cell.analysisUserModel(model:self.CommentInfos[indexPath.row])
            }
            return cell
        }
        
    }
    
    //    MARK:加载数据
    func loadData(isLoadMore:Bool) {
        ESDesignerApi.loadEvaluateList(designId: self.designId, offset: self.offset, limit: self.limit, success: { (response) in
//            if response != nil {
            
            let data = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted) as Data
            
            
            self.model = try? JSONDecoder().decode(ESGradeModel.self, from: data!) as ESGradeModel
            self.CommentInfos = (self.model.data?.comments)!

            
            self.tableView.reloadData()
            
        }) { (error) in
            
        }
    }
    
    
    //    MARK:懒加载
    lazy var tableView:UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.stec_viewBackground()
        tableView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight - 64)
        
        tableView.register(UINib.init(nibName: "ESGradeStarCell", bundle: nil), forCellReuseIdentifier: "ESGradeStarCell")
        tableView.register(UINib.init(nibName: "ESGradeMsgTableViewCell", bundle: nil), forCellReuseIdentifier: "ESGradeMsgTableViewCell")
        tableView.tableFooterView = UIView()
        
//        tableView.mj_footer.setRefreshingTarget(self, refreshingAction: Selector(("loadMoreData")))
        return tableView
    }()

    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    


}
