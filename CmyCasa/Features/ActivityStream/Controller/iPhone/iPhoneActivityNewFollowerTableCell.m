//
//  ActivityNewFollowerTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "iPhoneActivityNewFollowerTableCell.h"
#import "UIView+Alignment.h"
#import "UILabel+Size.h"

@interface iPhoneActivityNewFollowerTableCell ()

@end


@implementation iPhoneActivityNewFollowerTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

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
    return 140.0;
}

#pragma mark - Overrides

- (void)refreshUI
{
    
    self.privateTitleFormat = ACTIVITY_CELL_TITLE_FORMAT_PRIVATE_FOLLOWER_IPH;
    self.publicTitleFormat = ACTIVITY_CELL_TITLE_FORMAT_PUBLIC_FOLLOWER_IPH;
    self.privatePublicTitleFormat = PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_PUBLIC_FOLLOWER_IPH;

    [super refreshUI];
    
    CGSize newHeight = [self.lblHeader getActualTextHeightForLabelWithCGFloat:100];
    CGRect currentFrame = self.lblHeader.frame;
    [self.lblHeader setFrame:CGRectMake(currentFrame.origin.x, currentFrame.origin.y, newHeight.width, newHeight.height)];
    
    [self.btnFollow sizeToFit];
    self.btnFollow.frame = CGRectMake(self.btnFollow.frame.origin.x, self.btnFollow.frame.origin.y, self.btnFollow.frame.size.width, 28);
    if (self.btnFollow.frame.size.width < 129)
    {
        self.btnFollow.frame = CGRectMake(self.btnFollow.frame.origin.x, self.btnFollow.frame.origin.y, 129, self.btnFollow.frame.size.height);
    }
    
    [self alignHeader];
}

@end
