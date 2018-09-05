//
//  ESTitleSubTitleTableViewCell.h
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESTitleSubTitleTableViewCell : UITableViewCell
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle;
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle titleColor:(UIColor *)titleColor subTitleColor:(UIColor *)subTitleColor;
@end
