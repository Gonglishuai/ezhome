//
//  ESReDetailAddressCell.h
//  demo
//
//  Created by shiyawei on 12/4/18.
//  Copyright © 2018年 hu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESRecDetailAddressCell;

@protocol ESRecDetailAddressCellDelegate <NSObject>
@optional
- (void)esRecDetailAddressCell:(ESRecDetailAddressCell *)cell didEndEditing:(NSString *)detailAddress;
@end

@interface ESRecDetailAddressCell : UITableViewCell
@property (nonatomic,weak)    id <ESRecDetailAddressCellDelegate>delegate;
@end
