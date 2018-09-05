//
//  ESCaseHeaderView.h
//  Consumer
//
//  Created by jiang on 2017/8/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESCaseHeaderView : UITableViewHeaderFooterView
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle subImgName:(NSString *)imgName subTitleColor:(UIColor *)subTitleColor tapBlock:(void(^)(void))tapBlock;
@end
