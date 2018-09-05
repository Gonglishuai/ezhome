//
//  ESOrderDescriptionCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESOrderDescriptionCellDelegate <NSObject>

/**
 获取内容

 @return 内容
 */
- (NSString *)getDescription;

@end

@interface ESOrderDescriptionCell : UITableViewCell

@property (nonatomic, weak) id<ESOrderDescriptionCellDelegate> delegate;

- (void)updateDescriptionCell;
@end
