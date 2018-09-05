//
//  ESProProjectDetailProtocol.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/11.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

protocol ESProProjectDetailCellDelegate: NSObjectProtocol, ESTableViewCellProtocol,
    ESProProjectRejectCancelCellDelegate,
    ESProProjectDesignerCellDelegate,
    ESProProjectContractCellDelegate,
ESProProjectCostInfoCellDelegate,
ESProProjectPreviewInfoCellDelegate,
ESProProjectDeliveryInfoCellDelegate {

}

protocol ESProProjectDetailCellProtocol {
    weak var delegate: ESProProjectDetailCellDelegate? {get set}
    func updateCell(index: Int, section: Int)
}
