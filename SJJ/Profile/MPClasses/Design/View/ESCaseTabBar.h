//
//  ESCaseTabBar.h
//  Consumer
//
//  Created by jiang on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESCaseDetailModel.h"
@interface ESCaseTabBar : UIView
- (void)setEdgeInsets;
+ (instancetype)creatWithFrame:(CGRect)frame Block:(void(^)(NSString*))block; //2加入我的样板间   3预约
- (void)setWithPersonInfo:(ESCaseDetailModel *)caseDetailModel;
@end
