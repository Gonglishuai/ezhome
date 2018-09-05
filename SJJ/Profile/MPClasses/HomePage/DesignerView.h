//
//  DesignerView.h
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeConsumerDesignerModel;

typedef void (^NormalClickBlock)(void);

@interface DesignerView : UIView
- (void)setDataSource:(HomeConsumerDesignerModel *)model calculateBlock:(NormalClickBlock)block;
@end
