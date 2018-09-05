//
//  ESMemberInfoCell.h
//  Mall
//
//  Created by 焦旭 on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESMemberInfoViewModel.h"

@protocol ESMemberInfoCellDelegate <NSObject>

/**
 获取基本数据

 @param index 索引
 @return 基本信息页面模型
 */
- (ESMemberInfoViewModel *)getInfoModel:(NSInteger)index;

- (void)textFieldEditComplete:(UITextField *)textField withKey:(NSString *)key;

- (void)textFieldEditBegin:(UITextField *)textField withKey:(NSString *)key;
@end

@interface ESMemberInfoCell : UITableViewCell
@property (nonatomic, weak) id<ESMemberInfoCellDelegate> delegate;

- (void)updateCell:(NSInteger)index;
@end
