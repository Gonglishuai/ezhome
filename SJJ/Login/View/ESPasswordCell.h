//
//  ESPasswordCell.h
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESPasswordCell;
@protocol ESPasswordCellDelegate <NSObject>
@optional
- (void)esPasswordCell:(ESPasswordCell *)cell textShouldChange:(BOOL)enable;
- (void)esPasswordCell:(ESPasswordCell *)cell textDidEndEditing:(NSString *)text;
@end
@interface ESPasswordCell : UITableViewCell
@property (nonatomic,weak)    id<ESPasswordCellDelegate>delegate;
@property (nonatomic,assign)    BOOL isCreateEyeBtn;
@end
