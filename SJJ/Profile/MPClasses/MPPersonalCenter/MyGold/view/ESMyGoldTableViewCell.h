//
//  ESMyGoldTableViewCell.h
//  Mall
//
//  Created by jiang on 2017/9/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESMyGoldTableViewCell : UITableViewCell
- (void)setType:(NSString *)type info:(NSDictionary *)info block:(void(^)(void))block;
@end
