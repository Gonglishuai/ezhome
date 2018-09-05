//
//  ESAccountSettingTableCell.h
//  Homestyler
//
//  Created by shiyawei on 28/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ESAccountSettingTableCellType) {
    ESAccountSettingTableCellTypeSlected,//可选
    ESAccountSettingTableCellTypeAccessory,//向右的箭头
    ESAccountSettingTableCellTypeNone//无右侧图标
};

@interface ESAccountSettingTableCell : UITableViewCell
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,strong)    UILabel *subLabel;
@property (nonatomic,strong)    UILabel *detailLabel;
@property (nonatomic,assign)    ESAccountSettingTableCellType cellType;
@property (nonatomic,assign)    BOOL isSelected;
@end
