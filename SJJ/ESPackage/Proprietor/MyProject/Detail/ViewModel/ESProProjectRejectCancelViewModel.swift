//
//  ESProProjectRejectCancelViewModel.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESProProjectRejectCancelViewModel: ESViewModel {
    var type: RejectCancelType = .none
    
    enum RejectCancelType {
        case none
        case rejected(title: String, reason: String)
        case canceled(reason: String)
    }
}
