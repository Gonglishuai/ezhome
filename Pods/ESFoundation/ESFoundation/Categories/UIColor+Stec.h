//
//  UIColor+Stec.h
//  Consumer
//
//  Created by 姜云锋 on 17/4/20.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>


#define COLOR(R, G, B, A) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:(A)]

// 16进制颜色
#define ColorFromRGA(rgbValue,A) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(A)]


@interface UIColor (Stec)

/**
 *  background colors
 */

/**0Xfafafa*/
+ (UIColor *)stec_tabbarBackgroundColor;//tabbar背景色
/**0Xf9f9f9*/
+ (UIColor *)stec_viewBackgroundColor;//背景色
/**0X0X2696c4*/
+ (UIColor *)stec_ableButtonBackColor;//可点击按钮背景色
/**0X0X2696c4*/
+ (UIColor *)stec_buttonBackColor;
/**0Xfad17a*/
+ (UIColor *)stec_unabelButtonBackColor;//不可点击按钮背景色
/**0XC7D1D6*/
+ (UIColor *)stec_disabelButtonBackColor;
/**0Xf4f7f9*/
+ (UIColor *)stec_deleteButtonBackColor;//编辑 删除按钮 的背景颜色
/**0XDB4F44*/
+ (UIColor *)stec_deleteRowActionBackColor;//左划删除背景色
/**0Xf7f7f7*/
+ (UIColor *)stec_toolBackgroundColor;
/**0Xed7373*/
+ (UIColor *)stec_redBackgroundColor;

/**
 *  font colors
 */

/**0X2d2d34*/
+ (UIColor *)stec_titleTextColor;//正文、标题
/**0X7a7b87*/
+ (UIColor *)stec_subTitleTextColor;//副文本、副标题
/**0Xc7d1d6*/
+ (UIColor *)stec_contentTextColor;//最浅文字
/**0X2696c4*/
+ (UIColor *)stec_blueTextColor;//蓝色字
///浅蓝
+ (UIColor *)stec_lightBlueTextColor;
/**0X222227*/
+ (UIColor *)stec_titleDarkColor;
/**0Xffffff*/
+ (UIColor *)stec_whiteTextColor;//白色字
/**0X67AAC6*/
+ (UIColor *)stec_phoneTextColor;//联系商家电话号码字体颜色
/**0xd8d8d8*/
+ (UIColor *)stec_lightTextColor;
/**0xef8779*/
+ (UIColor *)stec_redLightColor;
/**0xdf473b*/
+ (UIColor *)stec_redDeepColor;
/**0xd0d0d0*/
+ (UIColor *)stec_grayBackgroundTextColor;
/**0x67c23a*/
+ (UIColor *)stec_selectedTextColor;
/**0xb3b3b3*/
+ (UIColor *)stec_unSelectedTextColor;
/**0x666666*/
+ (UIColor *)stec_priceTextColor;
/**0x96b1c3*/
+ (UIColor *)stec_itemSelectedTextColor;

/**
 *  seperate colors
 */
/**0Xebeced*/
+ (UIColor *)stec_lineGrayColor;//灰色线
/**0X2696c4*/
+ (UIColor *)stec_lineBlueColor;//蓝色线
/**0XECECEB*/
+ (UIColor *)stec_lineBorderColor;


//--------------------------------------------------

/**0Xdb4f44*/
+ (UIColor *)stec_redTextColor;//红色

/**0X82c65f*/
+ (UIColor *)stec_greenPaleTextColor;//绿色

/**0X8ac441*/
+ (UIColor *)stec_greenStatusTextColor;

/**0Xd1d9dd*/
+ (UIColor *)stec_lightStatusTextColor;

/**0Xff9b02*/
+ (UIColor *)stec_orangeTextColor;//橙黄色

/**0Xc6d1d3*/
+ (UIColor *)stec_grayTextColor;//灰色

/**0Xc7d1d6*/
+ (UIColor *)stec_placeholderTextColor;//预留文字颜色

/**0X2696c4*/
+ (UIColor *)stec_tabbarTextColor;

/**0X7a7b87*/
+ (UIColor *)stec_tabbarNormalTextColor;
@end
