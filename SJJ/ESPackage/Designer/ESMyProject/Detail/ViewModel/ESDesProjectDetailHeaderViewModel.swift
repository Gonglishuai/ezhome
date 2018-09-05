//
//  ESDesProjectDetailHeaderViewModel.swift
//  ESPackage
//
//  Created by 焦旭 on 2017/12/27.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

import UIKit

class ESDesProjectDetailHeaderViewModel: NSObject {
    
    /// 标题 (描述，颜色)
    var title: (text: String?, font: UIFont?, color: UIColor?)
    
    /// 副标题 (描述，颜色，是否可点击)
    var subTitle: (text: String?, font: UIFont?, color: UIColor?, canClick: Bool) = (nil, nil, nil, false)
}
