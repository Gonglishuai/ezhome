//
//  ESMSGoldTableViewCell.h
//  Mall
//
//  Created by jiang on 2017/9/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESMSGoldTableViewCell : UITableViewCell
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle placeholder:(NSString *)placeholder textFieldText:(NSString *)textFieldText block:(void(^)(NSString*,void(^)(BOOL resetStatus)))block;
- (void)setCanUseGold:(NSString *)goldNum;
- (void)setKeyboardBlock:(void(^)(CGRect inSuperViewFrame))block;


/**
 返回 CanpointAmount

 @param datasSource NSDictionary
 @return NSString
 */
- (NSString *)returnCanpointAmount:(NSMutableDictionary *)datasSource;
@end
