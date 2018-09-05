//
//  ActivityItemCommentedTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "BaseActivityItemCommentedTableCell.h"
#import "UIView+Alignment.h"

@interface BaseActivityItemCommentedTableCell ()

- (IBAction)buttonPressedThumbnail:(id)sender;
- (IBAction)buttonPressedImage:(id)sender;
- (IBAction)buttonPressedComment:(id)sender;
- (IBAction)buttonPressedLike:(id)sender;
- (IBAction)buttonPressedAddComment:(id)sender;

@property (nonatomic) CGRect originalHeaderLabelFrame;

@end


@implementation BaseActivityItemCommentedTableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Store the header frame as it is dynamically changed in every reuse and we require it for reset
    self.originalHeaderLabelFrame = self.lblHeader.frame;
    [self.ivOwner setMaskToCircleWithBorderWidth:0.0 andColor:[UIColor clearColor]];
    self.originalHeaderLabelSize = self.lblHeader.frame.size;

    [self cleanFields];
    
    //localisations
    [self.btnAddComment setTitle:NSLocalizedString(@"activity_comment_button_title", @"") forState:UIControlStateNormal];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.lblHeader.frame = self.originalHeaderLabelFrame;

    [self cleanFields];
}

- (void)cleanFields
{
    self.ivOwner.image = nil;
    self.ivDesign.image = nil;
    self.lblHeader.text = nil;
    self.lblTimeDescription.text = nil;
    self.lblCommentsCount.text = nil;
    self.lblLikesCount.text = nil;
    self.tvActorComment.text = nil;
    self.tvCommentBox.text = nil;
    self.tvCommentBox.editable = YES;
    self.btnAddComment.hidden = NO;
    self.ivAddCommentIcon.hidden = NO;
}

#pragma mark - Static

+ (CGFloat)heightForCell
{
    return 100.0; //this will be overriden by subclass
}

#pragma mark - Overrides

- (void)refreshUI
{
    [super refreshUI];
    
    self.lblTimeDescription.text = self.timeDescription;
    self.lblCommentsCount.text = [NSString stringWithFormat:@"%d", self.commentCount];
    self.lblLikesCount.text = [NSString stringWithFormat:@"%d", self.likeCount];
    
    //images loading
    [self setImageFromURLWithDefaultImage:self.actorImageUrl forImageView:self.ivOwner defaultImage:[UIImage imageNamed:@"profile_page_image"]];
    [self setImageFromURL:self.assetImageUrl forImageView:self.ivDesign useSmartfit:NO];
    
    //comments logic
    //TODO: this should be replaced by the actor comment
    self.tvActorComment.text = self.assetText;
    
    NSString *strComment = nil;
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(getCommentForActivityId:timestamp:)]))
    {
        NSTimeInterval ti = self.dateTimestamp.timeIntervalSince1970;
        strComment = [self.delegate getCommentForActivityId:self.activityId timestamp:ti];
    }
    
    if ([self isActorTheCurrentUser]) //if the actor is also the current user than this is his comment, and he shouldn't have a comment box to add a reply
    {
        self.tvCommentBox.text = nil;
        self.tvCommentBox.editable = NO;
        self.ivCommentBox.hidden = YES;
        self.btnAddComment.hidden = YES;
        self.ivAddCommentIcon.hidden = YES;
    }
    else if (strComment != nil) //in case this user already replied to this comment, than he cannot reply again
    {
        self.tvCommentBox.text = strComment;
        self.tvCommentBox.editable = NO;
        self.ivCommentBox.hidden = YES;
        self.btnAddComment.hidden = YES;
        self.ivAddCommentIcon.hidden = NO;
    }
    else //else he can reply
    {
        self.btnAddComment.hidden = NO;
        self.ivCommentBox.hidden = NO;
        self.tvCommentBox.text = ACTIVITY_CELL_COMMENT_DEFAULT_COMMENT_PLACEHOLDER;
        self.ivAddCommentIcon.hidden = NO;
    }
}

#pragma mark - UI Actions

- (IBAction)buttonPressedThumbnail:(id)sender
{
    if (self.ownerId == nil)
    {
        return;
    }
    
    //if the owner is myself than do nothing
    NSString *myUserId = [[[UserManager sharedInstance] currentUser] userID];
    if ((myUserId != nil) && (self.ownerId != nil) && ([myUserId isEqualToString:self.ownerId]))
    {
        return;
    }
    
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openUserProfilePage:)]))
    {
        [self.delegate openUserProfilePage:self.ownerId];
    }
}

- (IBAction)buttonPressedImage:(id)sender
{
    if (self.assetId == nil)
    {
        return;
    }
    
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openFullScreen:withType:)]))
    {
        [self.delegate openFullScreen:self.assetId withType:self.assetType];
    }
}

- (IBAction)buttonPressedComment:(id)sender
{
    [self openCommentPageForCurrentAsset];
}

- (IBAction)buttonPressedLike:(id)sender
{
    [self likePressed];
}

- (IBAction)buttonPressedAddComment:(id)sender
{
    if ([self.tvCommentBox isFirstResponder])
    {
        //in case the uesr hasnt written anything
        if ([self.tvCommentBox.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0)
        {
            return; //error
        }
    }
    else
    {
        //in case the user just pressed the comment button while the placeholder is active
        if ([self.tvCommentBox.text isEqualToString:ACTIVITY_CELL_COMMENT_DEFAULT_COMMENT_PLACEHOLDER])
        {
            return;
        }
    }
    
    [self.tvCommentBox resignFirstResponder];
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentCelldidFinishWritingCommnet:forActivityId:)])
    {
        [self.delegate commentCelldidFinishWritingCommnet:self.tvCommentBox.text forActivityId:self.activityId];
    }
}

#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.tvCommentBox.text isEqualToString:ACTIVITY_CELL_COMMENT_DEFAULT_COMMENT_PLACEHOLDER])
    {
        self.tvCommentBox.text = @"";
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentBox:didStartEditingAtCell:)])
    {
        [self.delegate commentBox:textView didStartEditingAtCell:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    if ([self.tvCommentBox.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0)
    {
        self.tvCommentBox.text = ACTIVITY_CELL_COMMENT_DEFAULT_COMMENT_PLACEHOLDER;
        return;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}



@end
