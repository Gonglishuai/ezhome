//
//  ActivityDesignFeaturedTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "iPhoneActivityDesignFeaturedTableCell.h"
#import "UIView+Alignment.h"
#import "UILabel+Size.h"

@interface iPhoneActivityDesignFeaturedTableCell ()

@end

@implementation iPhoneActivityDesignFeaturedTableCell

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
    return 350.0;
}

#pragma mark - Overrides

- (void)refreshUI
{
    
    [super refreshUI];
    
    [self alignHeader];
}

@end
