//
//  CommentViewController.h
//  CmyCasa
//
//  Created by Gil Hadas on 12/31/12.
//
//

#import <UIKit/UIKit.h>
#import "ProtocolsDef.h"
#import "DiscussionViewController.h"
#import "AppCore.h"
#import "CommentsManager.h"

@interface CommentViewController : UIViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *currentUserImage;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextView *commentBody;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UITextView *commentTxtView;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIImageView *commentTextEditBg;
@property (weak, nonatomic) IBOutlet UIImageView *seperateBarImage;
@property (nonatomic, assign) id<DiscussionViewControllerDelegate> discussionDelegate;
@property (nonatomic, assign) NSString* localsUer;
@property (nonatomic, assign) BOOL isDefaultComment;
@property (nonatomic, assign) BOOL isCommentTextOpen;

- (int)addCommentWithCommentList:(NSMutableArray*)listComments  possition:(int)in_yPos isChild:(BOOL)isChild item:(GalleryItemDO*) in_item;
- (void)setOpenInputText;
- (BOOL)loginRequestEndedwithState:(BOOL) state;
- (IBAction)commentPressed:(id)sender;
- (void)loadUserImage;
- (void)loadReplyUserImage:(NSString*)thumburl;
- (IBAction)commentProfileClicked:(id)sender;
- (void)init:(CommentDO*)comment :(GalleryItemDO*) in_item;

@end
