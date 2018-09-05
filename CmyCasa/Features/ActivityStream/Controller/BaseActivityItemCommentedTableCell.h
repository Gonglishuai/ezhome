//
//  ActivityItemCommentedTableCell.h
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import <UIKit/UIKit.h>

#import "BaseActivityTableCell.h"

#define ACTIVITY_CELL_COMMENT_DEFAULT_COMMENT_PLACEHOLDER   NSLocalizedString(@"activity_design_add_a_commented", @"Add a comment")

@interface BaseActivityItemCommentedTableCell : BaseActivityTableCell <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView            *ivOwner;
@property (nonatomic, weak) IBOutlet UIImageView            *ivDesign;
@property (nonatomic, weak) IBOutlet UILabel                *lblTimeDescription;
@property (nonatomic, weak) IBOutlet UITextView             *tvActorComment;
@property (nonatomic, weak) IBOutlet UITextView             *tvCommentBox;
@property (nonatomic, weak) IBOutlet UIButton               *btnAddComment;
@property (nonatomic, weak) IBOutlet UIImageView            *ivCommentBox;
@property (nonatomic, weak) IBOutlet UIImageView            *ivAddCommentIcon;

- (void)cleanFields;

@end
