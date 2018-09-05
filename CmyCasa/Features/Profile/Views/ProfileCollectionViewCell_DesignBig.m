//
//  ProfileCollectionViewCell_DesignBig.m
//  EZHome
//
//  Created by xiefei on 5/3/18.
//

#import "ProfileCollectionViewCell_DesignBig.h"

#import "NSString+Contains.h"
#import "NSString+FormatNumber.h"
#import "NSString+Time.h"
#import "UIView+Border.h"

static const NSInteger DESCRIPTION_MAX_LINES = 4;

@interface ProfileCollectionViewCell_DesignBig()

//@property (weak, nonatomic) IBOutlet UILabel *timestamp;
@property (weak, nonatomic) IBOutlet UILabel *designTitle;
@property (weak, nonatomic) IBOutlet UILabel *designDescription;
@property (weak, nonatomic) IBOutlet UIView *bgViewForTouch;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UILabel *commentsCount;
@property (weak, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *moreActionsButton;

@end

@implementation ProfileCollectionViewCell_DesignBig

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doNothing)];
    tap.delegate = self;
    [self.bgViewForTouch addGestureRecognizer:tap];
}

- (void)resetUI {
    [super resetUI];
    self.shareButton.hidden = YES;
    self.moreActionsButton.hidden = YES;
    self.designDescription.hidden = YES;
    self.likeButton.userInteractionEnabled = YES;
}

- (void)refreshUI {
    [super refreshUI];
    //self.timestamp.text = [self.designModel.timestamp smartTime];
    self.designTitle.text = self.designModel.title;

    NSString * desc = [self.designModel._description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![NSString isNullOrEmpty:desc]) {
        self.designDescription.text = desc;
        self.designDescription.hidden = NO;
    }

    self.commentsButton.enabled = STATUS_PRIVATE != self.designModel.publishStatus;
    self.likeButton.enabled = STATUS_PRIVATE != self.designModel.publishStatus;

    self.commentsCount.text = [NSString formatNumber:[self.designModel.commentsCount intValue]];
    self.likesCount.text = [NSString formatNumber:[self.designModel.tempLikeCount intValue]];

    [self setLikeButtonImage:[self.designModel isUserLikesDesign]];
    if (self.isOwnerProfile && STATUS_PUBLISHED != self.designModel.publishStatus) {
        self.moreActionsButton.hidden = NO;
    } else {
        self.shareButton.hidden = NO;
    }
}

- (void)toggleLikeState {
    // TODO: check like count consistence (self.designModel.tempLikeCount vs [self.designModel getLikesCountForDesign])
    int likesCount = [self.designModel getLikesCountForDesign];
    likesCount += ([self.designModel isUserLikesDesign] ? -1 : 1);
    if (likesCount < 0) {
        likesCount = 0;
    }
    [self setLikesCountNumber:likesCount];
}

- (void)refreshLikeButton {
    [self setLikesCountNumber:[self.designModel getLikesCountForDesign]];
    [self setLikeButtonImage:[self.designModel isUserLikesDesign]];
}

- (void)setLikesCountNumber:(int)likesCountNum {
    self.likesCount.text = [NSString formatNumber:likesCountNum];
}

- (void)setLikeButtonImage:(BOOL)isLiked {
    if (self.likeButton == nil)
        return;
    [self.likeButton setImage:[UIImage imageNamed:isLiked ? @"like_active" : @"like"] forState:UIControlStateNormal];
}

+ (CGFloat)calcDesignDescrtiptionTextHeightForDesign:(GalleryItemDO *)item cellWidth:(CGFloat)width {
    NSString *text = [item._description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([NSString isNullOrEmpty:text])
        return 0;

    const CGFloat margin = 12;
    const CGFloat spacing = 10;

    width -= 2 * margin;

    // NOTE: use the font with style settings for this label
    UIFont * font = [UIFont fontWithName:@".SFUIText-Light" size:14]; // Text_Body3_Light in nss

    CGFloat maxLines = DESCRIPTION_MAX_LINES;
    CGSize maxSize = CGSizeMake(width, font.lineHeight * maxLines);
    CGRect textRect = [text boundingRectWithSize:maxSize
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];

    return ceil(textRect.size.height + spacing);
}

- (void)updateLikeStatus
{
    [self refreshLikeButton];
}

- (void)updateCommentsCount
{
    self.commentsCount.text = [NSString formatNumber:[self.designModel.commentsCount intValue]];;
}

#pragma mark - Actions

- (void)doNothing {

}

- (IBAction)addComment:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(designPressed:)]) {
        [self.delegate designPressed:self.designModel];
    }
}

- (IBAction)toggleLike:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toggleLikeStateForDesign: withLikeButton: preActionBlock: completionBlock:)]) {
        __weak typeof(self) weakSelf = self;
        [self.delegate toggleLikeStateForDesign:self.designModel
                                 withLikeButton:self.likeButton
                                 preActionBlock:^{
                                     if (weakSelf != nil) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [weakSelf toggleLikeState];
                                         });
                                     }
                                 }
                                completionBlock:^(NSString* designId, BOOL success) {
                                    if (weakSelf != nil) {
                                        __strong typeof(self) strongSelf = weakSelf;
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (success) {
                                            } else  {
                                                [strongSelf refreshLikeButton];
                                            }
                                        });
                                    }
                                }];
    }
}

- (IBAction)shareDesign:(id)sender {
    if (self.designImageView.image == nil)
        return;

    if (self.delegate && [self.delegate respondsToSelector:@selector(shareDesign:withDesignImage:)]) {
        [self.delegate shareDesign:self.designModel withDesignImage:self.designImageView.image];
    }
}

- (IBAction)showMoreActions:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share", @"Share") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self shareDesign:nil];
    }];

    UIAlertAction *editInfoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"edit_info", @"Edit Info") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(designEditPressed:)]) {
            [self.delegate designEditPressed:self.designModel];
        }
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_msg_button_cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];

    [alert addAction:shareAction];
    [alert addAction:editInfoAction];
    [alert addAction:cancelAction];

    if (IS_IPAD) {
        [alert setModalPresentationStyle:UIModalPresentationFormSheet];

        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = _moreActionsButton;
        popPresenter.sourceRect = _moreActionsButton.bounds;
    }

    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
