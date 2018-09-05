//
//  ESOrderDetailPersonTableViewCell.h
//  ESMall
//
//  Created by jiang on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESOrderDetailPersonTableViewCell : UITableViewCell
- (void)setAvatar:(NSString *)avatar name:(NSString *)name phone:(NSString *)phone phoneBlock:(void(^)(NSString *phoneNum))phoneBlock;
@end
