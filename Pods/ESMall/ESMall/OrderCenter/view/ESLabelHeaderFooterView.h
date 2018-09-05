//
//  ESLabelHeaderFooterView.h
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESLabelHeaderFooterView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
- (void)setTitle:(NSString *)title titleColor:(UIColor *)titleColor subTitle:(NSString *)subTitle subTitleColor:(UIColor *)subTitleColor backColor:(UIColor *)backColor;
@end
