//
//  ActivityDesignLikedTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "iPadActivityDesignLikedTableCell.h"
#import "TTTAttributedLabel.h"

@interface iPadActivityDesignLikedTableCell ()

@end


@implementation iPadActivityDesignLikedTableCell

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
    return 295.0;
}

#pragma mark - Overrides

- (void)refreshUI
{
    self.titleFormat = ACTIVITY_CELL_TITLE_FORMAT_DESIGN_LIKED;
    self.titleFormatAgg = ACTIVITY_CELL_TITLE_FORMAT_DESIGN_AGG_LIKED;
    self.titlePrivateFormatAgg = PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_AGG_LIKED;
    self.titlePrivateFormat = PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_LIKED;

    [super refreshUI];
    [self alignHeader];
}
@end
