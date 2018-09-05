//
//  UIView+SHExtension.h
//  Enterprise
//
//  Created by HONG on 16/7/26.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SHExtension)

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

+ (instancetype)viewFromXib;
@end
