//
//  ESNoteCodeTableCell.h
//  Homestyler
//
//  Created by shiyawei on 27/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//短信验证码
#import <UIKit/UIKit.h>

@class ESNoteCodeTableCell;

typedef void(^NoteCodeTableCellBlock)();

@protocol ESNoteCodeTableCellDelegate <NSObject>
@optional
- (void)esNoteCodeTableCell:(ESNoteCodeTableCell *)cell textShouldChange:(BOOL)enable;
- (void)esNoteCodeTableCell:(ESNoteCodeTableCell *)cell textDidEndEditing:(NSString *)text;
- (void)esNoteCodeTableCellReloadNoteCode;

@end

@interface ESNoteCodeTableCell : UITableViewCell

@property (nonatomic,weak)    id<ESNoteCodeTableCellDelegate>delegate;
// /60S过后仍未进行短信验证码校验
@property (nonatomic,copy)    NoteCodeTableCellBlock cellBlock;

///销毁计时器
- (void)invalidateTimer;
///开启定时器
- (void)fireTimer;
@end
