//
//  SlidingViewMange.h
//  ios——Demo
//
//  Created by 董鑫 on 16/7/19.
//  Copyright © 2016年 董鑫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CoSlidingViewMange : NSObject

- (id)initWithInnerView:(UIView*)_innerView containerView:(UIView *)_containerView;
- (void)slideViewIn;
- (void)slideViewOut;

@end
