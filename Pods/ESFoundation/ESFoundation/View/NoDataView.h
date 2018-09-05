//
//  NoDataView.h
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoDataView : UIView
+ (instancetype)creatWithImgName:(NSString *)imgName title:(NSString *)title buttonTitle:(NSString *)buttonTitle Block:(void(^)(void))block;
- (void)setWithImgName:(NSString *)imgName title:(NSString *)title buttonTitle:(NSString *)buttonTitle Block:(void(^)(void))block;
@end
