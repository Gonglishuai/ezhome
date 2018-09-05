//
//  ActivityItemCommentedTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "UIView+Alignment.h"
#import "iPhoneActivityItemCommentedTableCell.h"

@interface iPhoneActivityItemCommentedTableCell ()

@end


@implementation iPhoneActivityItemCommentedTableCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self cleanFields];
    
    //localisations
    [self.btnAddComment setTitle:NSLocalizedString(@"activity_comment_button_title", @"") forState:UIControlStateNormal];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self cleanFields];
}

- (void)cleanFields
{
    [super cleanFields];
}

#pragma mark - Static

+ (CGFloat)heightForCell
{
    return 375.0;
}

#pragma mark - Overrides

- (void)refreshUI
{
    [super refreshUI];
    
    NSDictionary *dicLinks = @{};
    NSString *strHeaderText = nil;
    if ([self.delegate isCurrentCellOfLoggedInUser] && [self isActorTheCurrentUser])
    {
        dicLinks = @{self.assetTitle : @"design"};
        strHeaderText = [NSString stringWithFormat:PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_COMMENT_IPH,self.assetTitle];
    }
    else
    {
        if (self.actorName && self.assetTitle) {
            dicLinks = @{self.actorName : @"actor",
                         self.assetTitle : @"design"};
        }else{
            dicLinks = @{};
        }
        strHeaderText = [NSString stringWithFormat:ACTIVITY_CELL_TITLE_FORMAT_DESIGN_COMMENT_IPH, self.actorName ,self.assetTitle];
    }
    
    // Set the proper formatting for iPad (One single line)
    [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblHeader
                                                      text:strHeaderText
                                     stringLinksDictionary:dicLinks];

    [self alignHeader];
}

@end
