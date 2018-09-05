//
//  ProductInfoTitleTableViewCell.m
//  Homestyler
//
//  Created by Dan Baharir on 11/18/14.
//
//

#import "ProductInfoTitleTableViewCell.h"

@implementation ProductInfoTitleTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.goToWebBtn setTitle:NSLocalizedString(@"shopping_list_go_to_website", @"") forState:UIControlStateNormal];
    [self.goToWebBtnForIpad setTitle:NSLocalizedString(@"shopping_list_go_to_website", @"") forState:UIControlStateNormal];
}
@end
