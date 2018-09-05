//
//  ActivityNewArticleTableCell.h
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import <UIKit/UIKit.h>

#import "BaseActivityTableCell.h"

@interface BaseActivityNewArticleTableCell : BaseActivityTableCell

@property (nonatomic, weak) IBOutlet UIImageView    *ivOwner;
@property (nonatomic, weak) IBOutlet UIImageView    *ivDesign;
@property (nonatomic, weak) IBOutlet UILabel        *lblTimeDescription;
@property (nonatomic, weak) IBOutlet UILabel        *lblArticleName;
@property (nonatomic, weak) IBOutlet UILabel        *lblArticleDescription;
@property (weak, nonatomic) IBOutlet UILabel        *lblReadMore;
@property (weak, nonatomic) IBOutlet UILabel        *lblArticleAuthor;

- (void)cleanFields;

@end
