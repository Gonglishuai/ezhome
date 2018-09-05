//
//  CommentCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/23/13.
//
//

#import <UIKit/UIKit.h>
#import "DiscussionsBaseViewController.h"

@interface CommentCell : UITableViewCell<UITextViewDelegate>

@property (weak, nonatomic) id<DisscussionCommentsDelegate> delegate;
@property (nonatomic) CommentDO * mycomment;

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *commentBtn;
@property (weak, nonatomic) IBOutlet UITextView *commentBody;
@property (weak, nonatomic) IBOutlet UITextField *commentBodytf;
@property (weak, nonatomic) IBOutlet UIImageView *seperateBarImage;
@property (weak, nonatomic) IBOutlet UIView *seperateView;

- (IBAction)commentProfileClicked:(id)sender;
- (IBAction)writeReplyComment:(id)sender;
- (IBAction)saveComment:(id)sender;
- (IBAction)writeNewComment:(id)sender;
- (void)initWithComment:(CommentDO*)comment;

@end
