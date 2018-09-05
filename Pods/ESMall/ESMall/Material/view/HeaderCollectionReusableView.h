//
//  HeaderCollectionReusableView.h
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle;

@end
