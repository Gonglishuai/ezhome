//
//  ESCase4to3ImageView.h
//  EZHome
//
//  Created by xiefei on 28/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESCaseDetailModel.h"

@interface ESCase4to3ImageView : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *caseImageView;
@property (weak, nonatomic) IBOutlet UILabel *numLab;
//只用于展示鸟瞰图处理
@property (nonatomic,strong)    ESCaseDetailModel *aerialViewModel;
//只用来处理鸟瞰图是否存在
+ (BOOL)getCellHeightModel:(ESCaseDetailModel *)aerialViewModel;
@end
