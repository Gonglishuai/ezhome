//
//  ESBrandRecommendTableViewCell.h
//  Consumer
//
//  Created by jiang on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESBrandRecommendTableViewCell : UITableViewCell
- (void)setInfo:(NSDictionary *)info productBlock:(void(^)(NSString *productId))productBlock;
@end
