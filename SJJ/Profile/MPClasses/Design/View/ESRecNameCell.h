//
//  ESReNameCell.h
//  demo
//
//  Created by shiyawei on 12/4/18.
//  Copyright © 2018年 hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESRecNameCell;

typedef NS_ENUM(NSUInteger, ESRecNameCellType) {
    ESRecNameCellTypeName,//业主姓名
    ESRecNameCellTypePhoneNumber//手机号
};

@protocol ESRecNameCellDelegate <NSObject>
@optional

/**
 业主手机号数据

 @param cell ESRecNameCell
 @param name 业主手机号
 */
- (void)esRecNameCell:(ESRecNameCell *)cell phoneNumber:(NSString *)phoneNumber;

/**
 业主姓名

 @param cell ESRecNameCell
 @param name 业主姓名
 */
- (void)esRecNameCell:(ESRecNameCell *)cell name:(NSString *)name;
/**
 错误提示

 @param cell ESRecNameCell
 @param reminder 错误提示内容
 */
- (void)esRecNameCell:(ESRecNameCell *)cell cellType:(ESRecNameCellType)cellType reminder:(NSString *)reminder;

@end

@interface ESRecNameCell : UITableViewCell

@property (nonatomic,assign)    ESRecNameCellType cellType;

@property (nonatomic,weak)    id <ESRecNameCellDelegate>delegate;

@end
