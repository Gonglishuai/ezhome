//
//  NSMutableAttributedString+Stec.h
//  ESFoundation
//
//  Created by jiang on 2017/11/17.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (Stec)

/**
 给UILabel赋值 带行间距的String
 
 @param tmpString String
 @param lineSpace CGFloat 5,8
 @return NSMutableAttributedString
 */
+ (NSMutableAttributedString *)retainAttributeString:(NSString *)tmpString linespace:(CGFloat)lineSpace;

@end
