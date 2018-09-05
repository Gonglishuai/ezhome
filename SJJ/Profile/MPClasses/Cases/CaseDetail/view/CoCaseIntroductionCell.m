//
//  CoCaseIntroductionCell.m
//  Consumer
//
//  Created by Jiao on 16/7/20.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoCaseIntroductionCell.h"
#import "ES2DCaseDetail.h"

@implementation CoCaseIntroductionCell
{
    
    __weak IBOutlet UILabel *_communityNameLabel;
    __weak IBOutlet UILabel *_introduceLabel;
    __weak IBOutlet NSLayoutConstraint *_introduceLabelHeightLayout;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateIntroductionCellWithIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(getIntroductionDetail)]) {
        ES2DCaseDetail * caseModel =[self.delegate getIntroductionDetail];
        if (caseModel != nil ) {
            
            _communityNameLabel.text = caseModel.communityName;
            NSString *str = [self formatDic:caseModel.caseDescription];
            CGSize size = [CoCaseIntroductionCell preferredMaxLayoutSizeForText:str withFont:_introduceLabel.font forMaxWidth:_introduceLabel.frame.size.width withSideMargins:0];
            CGFloat height = size.height + 12.1;
            height = height > 30 ? height : 30;
            _introduceLabelHeightLayout.constant = height;
            _introduceLabel.text = [NSString stringWithFormat:@"%@",str];
        }

    }
}

+ (CGSize)preferredMaxLayoutSizeForText:(NSString *)text
                               withFont:(UIFont *)font
                            forMaxWidth:(CGFloat)width
                        withSideMargins:(NSInteger)margin
{
    CGFloat preferredMaxLayoutWidth = width - (margin * 2);
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attributes = nil;
    if (font)
        attributes = @{NSFontAttributeName: font,
                       NSParagraphStyleAttributeName: [mutableParagraphStyle copy]};
    else
        attributes = @{NSParagraphStyleAttributeName: [mutableParagraphStyle copy]};
    
    CGRect boundingRect = [text boundingRectWithSize:CGSizeMake(preferredMaxLayoutWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    return boundingRect.size;
}

- (NSString *)formatDic:(id)obj {
    
    if ([obj isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    NSString *string =[NSString stringWithFormat:@"%@",obj];
    NSString *strUrl = [string stringByReplacingOccurrencesOfString:@"(null)" withString:@"暂无介绍"];
    
    NSString *strUrls = [strUrl stringByReplacingOccurrencesOfString:@"null" withString:@"暂无介绍"];
    
    return strUrls;
}



@end
