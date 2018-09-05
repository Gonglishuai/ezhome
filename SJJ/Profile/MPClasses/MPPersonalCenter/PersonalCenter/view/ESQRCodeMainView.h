//
//  ESQRCodeMainView.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESQRCodeMainViewDelegate <NSObject>

- (void)closeBtnClick;

@end

@interface ESQRCodeMainView : UIView

@property (nonatomic, weak) id<ESQRCodeMainViewDelegate> delegate;

- (void)setQRImage:(UIImage *)image;
@end
