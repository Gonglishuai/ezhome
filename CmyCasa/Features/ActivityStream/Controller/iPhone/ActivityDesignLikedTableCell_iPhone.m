//
//  ActivityDesignLikedTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "ActivityDesignLikedTableCell_iPhone.h"
#import "TTTAttributedLabel.h"
#import "UIView+Alignment.h"
#import "UILabel+Size.h"

@interface ActivityDesignLikedTableCell_iPhone ()

@end


@implementation ActivityDesignLikedTableCell_iPhone

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
    return 371.0;
}

#pragma mark - Overrides

- (void)refreshUI
{
    self.titleFormat = ACTIVITY_CELL_TITLE_FORMAT_DESIGN_LIKED_IPH;
    self.titleFormatAgg = ACTIVITY_CELL_TITLE_FORMAT_DESIGN_AGG_LIKED_IPH;
    self.titlePrivateFormatAgg = PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_AGG_LIKED_IPH;
    self.titlePrivateFormat = PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_LIKED_IPH;
    
    [super refreshUI];
        
    [self alignHeader];
}


#pragma mark - UI Actions


@end
