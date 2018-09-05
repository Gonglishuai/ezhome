//
//  ActivityNewArticleTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "iPadActivityNewArticleTableCell.h"
#import "UILabel+Size.h"
#import "UIView+Alignment.h"

@interface iPadActivityNewArticleTableCell ()

@end


@implementation iPadActivityNewArticleTableCell

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
    return 300.0;
}

#pragma mark - Overrides

- (void)refreshUI
{
    [super refreshUI];
    
    [self alignHeader];
}


@end
