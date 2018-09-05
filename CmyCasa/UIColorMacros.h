//
//  UIColorMacros.h
//  CmyCasa
//
//  Created by Or Sharir on 2/6/13.
//
//

#ifndef CmyCasa_UIColorMacros_h
#define CmyCasa_UIColorMacros_h

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromGrayLevelWithAlpha(grayLevel,a) [UIColor \
colorWithRed:((float)(grayLevel))/255.0 \
green:((float)(grayLevel))/255.0 \
blue:((float)(grayLevel))/255.0 alpha:a]

#define UIColorFromGrayLevel(grayLevel) UIColorFromGrayLevelWithAlpha(grayLevel, 1)


#endif
