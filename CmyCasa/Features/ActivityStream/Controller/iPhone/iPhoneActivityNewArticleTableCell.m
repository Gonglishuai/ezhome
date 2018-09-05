//
//  ActivityNewArticleTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "iPhoneActivityNewArticleTableCell.h"
#import "UILabel+Size.h"
#import "UIView+Alignment.h"

@interface iPhoneActivityNewArticleTableCell ()

@end


@implementation iPhoneActivityNewArticleTableCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)cleanFields
{
    [super cleanFields];
}

#pragma mark - Static

+ (CGFloat)heightForCell
{
    return 500.0;
}

#pragma mark - Overrides

- (void)refreshUI
{
    [super refreshUI];
    
    // Alignment of the heart and comment images + labels
    //[self.lblLikesCount sizeToFit];
    //[self.lblCommentsCount sizeToFit];
    //[self.lblLikesCount alignWithView:self.ivDesign type:eAlignmentRight];
    //[self.lblLikesCount appendViewWithMargin:self.btnLikes type:eAppendLeft margin:ACTIVITY_HEART_ICON_MARGIN_FROM_TEXT];
    //[self.btnLikes appendViewWithMargin:self.lblCommentsCount type:eAppendLeft margin:ACTIVITY_COMMENT_TEXT_MARGIN_FROM_HEART_ICON];
    //[self.lblCommentsCount appendViewWithMargin:self.btnComments type:eAppendLeft margin:ACTIVITY_COMMENT_ICON_MARGIN_FROM_COMMENT_TEXT];
    [self alignHeader];
}

@end
