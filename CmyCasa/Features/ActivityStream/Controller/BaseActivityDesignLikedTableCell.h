//
//  ActivityDesignLikedTableCell.h
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import <UIKit/UIKit.h>

#import "BaseActivityTableCell.h"

@interface BaseActivityDesignLikedTableCell : BaseActivityTableCell

@property (nonatomic, weak) IBOutlet UIImageView                *ivOwner;
@property (nonatomic, weak) IBOutlet UIImageView                *ivDesign;
@property (nonatomic, weak) IBOutlet UILabel                    *lblTimeDescription;

@property (strong, nonatomic) NSString                          *titleFormat;
@property (strong, nonatomic) NSString                          *titlePrivateFormat;
@property (strong, nonatomic) NSString                          *titleFormatAgg;
@property (strong, nonatomic) NSString                          *titlePrivateFormatAgg;

- (void)cleanFields;

@end
