//
//  ESCreatBrandListRecommdListCell.swift
//  Consumer
//
//  Created by zhang dekai on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESCreatBrandListRecommdListCellProtocol:NSObjectProtocol {
    ///删除品牌
    func deleteBrand(cellIndexPath:IndexPath)
    ///推荐理由
    func gotTextViewText(text:String, indexPath:IndexPath)
}

class ESCreatBrandListRecommdListCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var brandImageView: UIImageView!
    
    @IBOutlet weak var goodsName: UILabel!
    
    @IBOutlet weak var goodsType: UILabel!
    
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var placeHold: UILabel!
    
    private weak var cellDegate:ESCreatBrandListRecommdListCellProtocol?
    
    private var cellIndexPath:IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        brandImageView.layer.masksToBounds = true
        brandImageView.layer.borderWidth = 0.5
        brandImageView.layer.borderColor = ESColor.color(hexColor: 0xCDCDCD, alpha: 1).cgColor
       
        textView.delegate = self
        placeHold.isHidden = true
        textView.text = "请输入推荐理由"
    }
    
    func setDelegate(delegate:ESCreatBrandListRecommdListCellProtocol, indexPath: IndexPath){
        self.cellDegate = delegate
        self.cellIndexPath = indexPath
    }
    
    func setCellModel(model:ESBrandGoodsModel){
        goodsName.text = model.name ?? "--"
        goodsType.text = "品类:\(model.cat2Name ?? "--")"
        brandImageView.imageWith(model.logo ?? "", placeHold: #imageLiteral(resourceName: "nodata_datas"))
        
        let descriptionString = model.description ?? ""
        if descriptionString == ""  {
            textView.text = "请输入推荐理由"
        } else {
            textView.text = descriptionString
        }
    }
    
    private var deleteing = false
    @IBAction func deleteBrand(_ sender: Any) {
        deleteing = true
        if let delegate = cellDegate, let indexPath = self.cellIndexPath {
            delegate.deleteBrand(cellIndexPath: indexPath)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        let text = textView.text ?? ""

        if text == "请输入推荐理由" {
            textView.text = ""
        }
//        placeHold.isHidden = true

        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let text = textView.text ?? ""

        if text.count > 50 {
            textView.text = NSString(string: text).substring(to: 50)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
       
        let text = textView.text ?? ""
        
        if text == "" {
            textView.text = "请输入推荐理由"
        } else {
            textView.text = text
        }
        
        if let delegate = cellDegate,!deleteing {
            delegate.gotTextViewText(text: text, indexPath: cellIndexPath!)
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("多岁的")
        
    }
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
