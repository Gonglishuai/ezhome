//
//  ESProProjectDetailHeaderViewModel.swift
//  Consumer
//
//  Created by 焦旭 on 2018/1/10.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

import UIKit

class ESProProjectDetailHeaderViewModel: ESViewModel {
    /// 标题 (描述，颜色)
    var title: (text: String?, font: UIFont?, color: UIColor?)
    
    /// 副标题 (描述，字体，颜色，是否可点击)
    var subTitle: (text: String?, font: UIFont?, color: UIColor?, canClick: Bool) = (nil, nil, nil, false)
}
