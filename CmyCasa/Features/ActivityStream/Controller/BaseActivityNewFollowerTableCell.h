//
//  ActivityNewFollowerTableCell.h
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import <UIKit/UIKit.h>

#import "BaseActivityTableCell.h"

@interface BaseActivityNewFollowerTableCell : BaseActivityTableCell

@property (nonatomic, weak) IBOutlet UIImageView               *ivOwner;
@property (nonatomic, weak) IBOutlet UILabel                   *lblTimeDescription;
@property (nonatomic, weak) IBOutlet UIButton                  *btnFollow;

@property (strong, nonatomic) NSString                          *privateTitleFormat;
@property (strong, nonatomic) NSString                          *publicTitleFormat;
@property (strong, nonatomic) NSString                          *privatePublicTitleFormat;

- (void)cleanFields;

@end
