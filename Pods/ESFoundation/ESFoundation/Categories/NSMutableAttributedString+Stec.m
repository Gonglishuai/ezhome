//
//  NSMutableAttributedString+Stec.m
//  ESFoundation
//
//  Created by jiang on 2017/11/17.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import "NSMutableAttributedString+Stec.h"

@implementation NSMutableAttributedString (Stec)

+ (NSMutableAttributedString *)retainAttributeString:(NSString *)tmpString linespace:(CGFloat)lineSpace
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString:tmpString];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc]init];
    paragraph.lineSpacing = lineSpace;
    [attributeString addAttributes:@{NSParagraphStyleAttributeName:paragraph} range:NSMakeRange(0, tmpString.length)];
    
    return attributeString;
}

@end
