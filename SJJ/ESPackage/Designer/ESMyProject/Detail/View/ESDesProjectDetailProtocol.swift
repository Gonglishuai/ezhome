//
//  ESDesProjectDetailProtocol.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/24.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESDesProjectDetailCellDelegate: NSObjectProtocol, ESTableViewCellProtocol,
    ESDesProjectOrderDetailCellDelegate,
    ESDesProjectContractCellDelegate,
    ESDesProjectCostInfoCellDelegate,
    ESDesProjectPreviewCellDelegate,
    ESDesProjectQuoteInfoCellDelegate,
    ESDesProjectDeliveryInfoCellDelegate {
    
}

protocol ESDesProjectDetailCellProtocol {
    weak var delegate: ESDesProjectDetailCellDelegate? {get set}
    func updateCell(index: Int, section: Int)
}
