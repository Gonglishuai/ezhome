
#import "ESSampleRoomModel.h"
#import <ESFile.h>

@implementation ESSampleRoomModel

- (id)createModelWithDic:(NSDictionary *)dic
{
    [super createModelWithDic:dic];
    
    [self updateModel];
    
    [self updateLabels:dic[@"feature"]];
    
    return self;
}

- (void)updateModel
{
    [self updateImages];
    
    [self updateCaseInformation];
}

- (void)updateImages
{
    if (self.defaultImg
        && [self.defaultImg isKindOfClass:[NSString class]]
        && self.defaultImg.length > 0)
    {
        self.defaultImg = [ESFile getImageUrl:self.defaultImg
                                     withType:ESFileTypeHD];
    }
    else
    {
        self.defaultImg = @"";
    }
    
    if (self.designerAvatar
        && [self.designerAvatar isKindOfClass:[NSString class]]
        && self.designerAvatar.length > 0)
    {
//        self.designerAvatar = [NSString stringWithFormat:@"%@_%d_%d.img",
//                               self.designerAvatar,
//                               120,
//                               120];
    }
    else
    {
        self.designerAvatar = @"";
    }
}

- (void)updateCaseInformation
{
    if (self.caseType
        && [self.caseType isKindOfClass:[NSString class]])
    {
        if ([self.caseType isEqualToString:@"1"])
        {
            self.caseEnumType = CaseType2D;
        }
        else if ([self.caseType isEqualToString:@"2"])
        {
            self.caseEnumType = CaseType3D;
        }
        else
        {
            self.caseEnumType = CaseTypeUnKnow;
        }
    }
    
    if (self.caseVersion
        && [self.caseVersion isKindOfClass:[NSString class]])
    {
        if ([self.caseVersion isEqualToString:@"1"])
        {
            self.caseEnumVersion = CaseVersionOld;
        }
        else if ([self.caseVersion isEqualToString:@"2"])
        {
            self.caseEnumVersion = CaseVersionNew;
        }
        else
        {
            self.caseEnumVersion = CaseVersionUnknow;
        }
    }
}

- (void)updateLabels:(NSArray *)labels
{
    if (!labels
        || ![labels isKindOfClass:[NSArray class]])
    {
        self.rightLabelWidth = 0.0f;
        self.rightLabelText  = @"";
        self.midLabelWidth   = 0.0f;
        self.midLabelText    = @"";
        self.leftLabelWidth  = 0.0f;
        self.leftLabelText   = @"";
        return;
    }
    
    if (SCREEN_WIDTH >= 414 - 1)
    {
        [self updateRightLabel:labels];
        [self updateMidLabel:labels];
        [self updateLeftLabel:labels];
    }
    else if (SCREEN_WIDTH >= 320 + 1 && SCREEN_WIDTH <= 375 + 1)
    {
        [self updateRightLabel:labels];
        [self updateMidLabel:labels];
        
        self.leftLabelWidth  = 0.0f;
        self.leftLabelText   = @"";
    }
    else
    {
        [self updateRightLabel:labels];
        
        self.midLabelWidth   = 0.0f;
        self.midLabelText    = @"";
        self.leftLabelWidth  = 0.0f;
        self.leftLabelText   = @"";
    }
}

- (void)updateLeftLabel:(NSArray *)labels
{
    if (labels.count > 2
        && [labels[2] isKindOfClass:[NSString class]])
    {
        NSString *label = labels[2];
        CGSize labelSize = [ESSampleRoomModel getTextSize:label];
        self.leftLabelWidth = labelSize.width;
        self.leftLabelText  = labelSize.width > 0 ? [@"#" stringByAppendingString:label] : @"";
        
    }
    else
    {
        self.leftLabelWidth = 0.0f;
        self.leftLabelText  = @"";
    }
}

- (void)updateMidLabel:(NSArray *)labels
{
    if (labels.count > 1
        && [labels[1] isKindOfClass:[NSString class]])
    {
        NSString *label = labels[1];
        CGSize labelSize = [ESSampleRoomModel getTextSize:label];
        self.midLabelWidth = labelSize.width;
        self.midLabelText  = labelSize.width > 0 ? [@"#" stringByAppendingString:label] : @"";
        
    }
    else
    {
        self.midLabelWidth = 0.0f;
        self.midLabelText  = @"";
    }
}

- (void)updateRightLabel:(NSArray *)labels
{
    if (labels.count > 0
        && [[labels firstObject] isKindOfClass:[NSString class]])
    {
        NSString *label = [labels firstObject];
        CGSize labelSize = [ESSampleRoomModel getTextSize:label];
        self.rightLabelWidth = labelSize.width;
        self.rightLabelText  = labelSize.width > 0 ? [@"#" stringByAppendingString:label] : @"";
    }
    else
    {
        self.rightLabelWidth = 0.0f;
        self.rightLabelText  = @"";
    }
}

+ (CGSize)getTextSize:(NSString *)text
{
    if (!text
        || ![text isKindOfClass:[NSString class]]
        || text.length <= 0)
    {
        return CGSizeZero;
    }
    
    text = [NSString stringWithFormat:@" #%@ ", text];
    // font需跟ESModelTagLabel中使用的font一致
    UIFont *font = [UIFont stec_tagFount];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 20)
                                     options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName : font}
                                     context:nil];
    return rect.size;
}

@end
