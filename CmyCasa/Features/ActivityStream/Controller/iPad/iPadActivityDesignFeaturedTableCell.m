//
//  ActivityDesignFeaturedTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "iPadActivityDesignFeaturedTableCell.h"
#import "UILabel+Size.h"
#import "UIView+Alignment.h"

@interface iPadActivityDesignFeaturedTableCell ()

@end

@implementation iPadActivityDesignFeaturedTableCell

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
    
    [super refreshUI];

    [self alignHeader];
}

@end
