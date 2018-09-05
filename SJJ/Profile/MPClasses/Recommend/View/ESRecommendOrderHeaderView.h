//
//  ESRecommendOrderHeaderView.h
//  Consumer
//
//  Created by jiang on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESRecommendOrderHeaderView : UITableViewHeaderFooterView

/**
 赋值

 @param avatar 头像
 @param name 名字
 @param phone 电话
 @param title 标题
 @param subTitle 副标题
 @param subTitleColor 副标题字体颜色
 @param phoneBlock 电话回调
 */
- (void)setAvatar:(NSString *)avatar name:(NSString *)name phone:(NSString *)phone Title:(NSString *)title subTitle:(NSString *)subTitle subTitleColor:(UIColor *)subTitleColor phoneBlock:(void(^)(NSString *phoneNum))phoneBlock;
@end
