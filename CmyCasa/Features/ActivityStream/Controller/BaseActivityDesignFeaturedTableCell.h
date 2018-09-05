//
//  ActivityDesignFeaturedTableCell.h
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import <UIKit/UIKit.h>

#import "BaseActivityTableCell.h"



@interface BaseActivityDesignFeaturedTableCell : BaseActivityTableCell

@property (nonatomic, weak) IBOutlet UIImageView                *ivOwner;
@property (nonatomic, weak) IBOutlet UIImageView                *ivDesign;
@property (nonatomic, weak) IBOutlet UILabel                    *lblTimeDescription;
@property (weak, nonatomic) IBOutlet UIImageView                *ivFeatured;


- (void)cleanFields;

@end
