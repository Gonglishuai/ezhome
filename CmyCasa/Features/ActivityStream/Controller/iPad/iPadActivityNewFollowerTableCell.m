//
//  ActivityNewFollowerTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "iPadActivityNewFollowerTableCell.h"
#import "UIView+Alignment.h"

@interface iPadActivityNewFollowerTableCell ()

@end


@implementation iPadActivityNewFollowerTableCell

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
    return 125.0;
}

#pragma mark - Overrides

- (void)refreshUI
{
    self.privateTitleFormat = ACTIVITY_CELL_TITLE_FORMAT_PRIVATE_FOLLOWER;
    self.publicTitleFormat = ACTIVITY_CELL_TITLE_FORMAT_PUBLIC_FOLLOWER;
    self.privatePublicTitleFormat = PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_PUBLIC_FOLLOWER;

    [super refreshUI];
        
    [self.btnFollow sizeToFit];
    self.btnFollow.frame = CGRectMake(self.btnFollow.frame.origin.x, self.btnFollow.frame.origin.y, self.btnFollow.frame.size.width, 28);
    if (self.btnFollow.frame.size.width < 129)
    {
        self.btnFollow.frame = CGRectMake(self.btnFollow.frame.origin.x, self.btnFollow.frame.origin.y, 129, self.btnFollow.frame.size.height);
    }
    
    [self alignHeader];
}


@end
