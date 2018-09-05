//
//  UIFont+Stec.m
//  Consumer
//
//  Created by 姜云锋 on 17/4/20.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "UIFont+Stec.h"

@implementation UIFont (Stec)

/**字号：17*/
+ (UIFont *)stec_navigationBarTitleFount {
    return [UIFont fontWithSize:17];
}

/**字号：21*/
+ (UIFont *)stec_largeTitleFount {
    return [UIFont fontWithSize:21];
}

/**字号：18*/
+ (UIFont *)stec_bigerTitleFount {
    return [UIFont fontWithSize:18];
}

/**字号：16*/
+ (UIFont *)stec_bigTitleFount {
    return [UIFont fontWithSize:16];
}

/**字号：14*/
+ (UIFont *)stec_titleFount {
    return [UIFont fontWithSize:14];
}

/**字号：13*/
+ (UIFont *)stec_subTitleFount {
    return [UIFont fontWithSize:13];
}

/**字号：12*/
+ (UIFont *)stec_remarkTextFount {
    return [UIFont fontWithSize:12];
}

/**字号：16*/
+ (UIFont *)stec_buttonFount {
    return [UIFont fontWithSize:16];
}

/**字号：19*/
+ (UIFont *)stec_packageSubBigTitleFount {
    return [UIFont fontWithSize:19];
}

/**字号：20*/
+ (UIFont *)stec_packageTitleFount {
    return [UIFont fontWithSize:20];
}

/**字号：23*/
+ (UIFont *)stec_packageTitleBigFount {
    return [UIFont fontWithSize:23];
}

/**字号：9*/
+ (UIFont *)stec_tabbarFount {
    return [UIFont fontWithSize:9];
}

/**字号：10*/
+ (UIFont *)stec_headerFount {
    return [UIFont fontWithSize:10];
}

/**字号：11*/
+ (UIFont *)stec_tagFount {
    return [UIFont fontWithSize:11];
}

/**字号：13 中黑体*/
+ (UIFont *)stec_phoneNumberFount {
    UIFont *font = [UIFont fontWithName:Font_style_medium size:13];
    if (!font)
    {
        font = [UIFont systemFontOfSize:13];
    }
    
    return font;
}

/**字号：13 细体*/
+ (UIFont *)stec_paramsFount {
    UIFont *font = [UIFont fontWithName:Font_style_light size:13];
    if (!font)
    {
        font = [UIFont systemFontOfSize:13];
    }
    
    return font;
}

/**字号：12 细体*/
+ (UIFont *)stec_priceFount {
    UIFont *font = [UIFont fontWithName:Font_style_light size:12];
    if (!font)
    {
        font = [UIFont systemFontOfSize:12];
    }
    
    return font;
}

/**字号：16 细体*/
+ (UIFont *)stec_lightPriceFount {
    UIFont *font = [UIFont fontWithName:Font_style_light size:16];
    if (!font)
    {
        font = [UIFont systemFontOfSize:16];
    }
    
    return font;
}

/**字号：18 中黑体*/
+ (UIFont *)stec_mediumPriceFount {
    UIFont *font = [UIFont fontWithName:Font_style_medium size:18];
    if (!font)
    {
        font = [UIFont systemFontOfSize:18];
    }
    
    return font;
}

+ (UIFont *)fontWithSize:(CGFloat)fontSize
{
    UIFont *font = [UIFont fontWithName:Font_style size:fontSize];
    if (!font)
    {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}
NSString *const Font_style = @"PingFangSC-Regular";
NSString *const Font_style_light = @"PingFangSC-Light";
NSString *const Font_style_medium = @"PingFangSC-Medium";

@end
