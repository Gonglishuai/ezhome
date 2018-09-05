//
//  UIFont+Stec.h
//  Consumer
//
//  Created by 姜云锋 on 17/4/20.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Stec)

/**字号：17*/
+ (UIFont *)stec_navigationBarTitleFount;

/**字号：21*/
+ (UIFont *)stec_largeTitleFount;

/**字号：16*/
+ (UIFont *)stec_bigTitleFount;

/**字号：14*/
+ (UIFont *)stec_titleFount;

/**字号：13*/
+ (UIFont *)stec_subTitleFount;

/**字号：12*/
+ (UIFont *)stec_remarkTextFount;

/**字号：18*/
+ (UIFont *)stec_bigerTitleFount;

/**字号：16*/
+ (UIFont *)stec_buttonFount;

/**字号：19*/
+ (UIFont *)stec_packageSubBigTitleFount;

/**字号：20*/
+ (UIFont *)stec_packageTitleFount;

/**字号：23*/
+ (UIFont *)stec_packageTitleBigFount;

/**字号：9*/
+ (UIFont *)stec_tabbarFount;

/**字号：10*/
+ (UIFont *)stec_headerFount;

/**字号：11*/
+ (UIFont *)stec_tagFount;

/**字号：13 中黑体*/
+ (UIFont *)stec_phoneNumberFount;

/**字号：13 细体*/
+ (UIFont *)stec_paramsFount;

/**字号：12 细体*/
+ (UIFont *)stec_priceFount;

/**字号：16 细体*/
+ (UIFont *)stec_lightPriceFount;

/**字号：18 中黑体*/
+ (UIFont *)stec_mediumPriceFount;

+ (UIFont *)fontWithSize:(CGFloat)fontSize;
    
@end
