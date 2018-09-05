//
//  MessagesCell.m
//  Homestyler
//
//  Created by liuyufei on 4/27/18.
//

#import "MessagesCell.h"
#import "FollowUserInfo.h"
#import "NotificationContentDO.h"
#import "NotificationDetailDO.h"
#import "NotificationDesignInfoDO.h"

#import "HSFollowButton.h"

#import "NSString+Contains.h"
#import "NSString+Time.h"
#import "UIImageView+LoadImage.h"


@interface MessagesCell()

@property (weak, nonatomic) IBOutlet UIImageView *avatarProfile;

@property (weak, nonatomic) IBOutlet UILabel *messageDescription;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateTime;

@property (weak, nonatomic) IBOutlet HSFollowButton *followButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *designImg;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarProfileConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *designImgConstraint;

@end

@implementation MessagesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.designImgConstraint.constant = IS_IPAD ? 40 : 20;
    self.followConstraint.constant = IS_IPAD ? 40 : 20;
    self.avatarProfileConstraint.constant = IS_IPAD ? 40 : 20;

    UITapGestureRecognizer * tapAvatar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnAvatar:)];
    tapAvatar.delegate = self;
    [self.avatarProfile addGestureRecognizer:tapAvatar];

    UITapGestureRecognizer * tapDesignImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnDesignImage:)];
    tapDesignImage.delegate = self;
    [self.designImg addGestureRecognizer:tapDesignImage];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.avatarProfile.image = nil;
    self.designImg.image = nil;

    self.designImg.hidden = YES;
    self.followButton.hidden = YES;
    self.followButton.isFollowing = NO;
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

- (void)setDetail:(NotificationDetailDO *)detail
{
    if (!detail)
        return;

    _detail = detail;
    [self setupMessagesDetail];
}

- (void)setupMessagesDetail
{
    FollowUserInfo *userInfo = self.detail.fromUser;
    NotificationDesignInfoDO *designInfo = self.detail.designInfo;

    self.avatarProfile.image = [UIImage imageNamed:@"user_avatar"];
    [self.avatarProfile loadImageFromUrl:userInfo.photoUrl defaultImageName:@"user_avatar"];

    NSString *userName = [userInfo getUserFullName];

    self.lastUpdateTime.text = [self.detail.createTime smartTime];

    if ([self.detail.noticeType isEqualToString:@"LIKE"])
    {
        [self setupLikeFromUserName:userName designInfo:designInfo];
    }
    else if ([self.detail.noticeType isEqualToString:@"FOLLOW"])
    {
        [self setupFollowFromUserName:userName userInfo:userInfo];
    }
    else if ([self.detail.noticeType isEqualToString:@"FEATURE"])
    {
        [self setupFeaturedWithDesignInfo:designInfo];
    }
    else if ([self.detail.noticeType isEqualToString:@"COMMENT"])
    {
        [self setupCommentFromUserName:userName designInfo:designInfo];
    }
    //other
}

- (void)setupLikeFromUserName:(NSString *)userName designInfo:(NotificationDesignInfoDO *)designInfo
{
    self.designImg.userInteractionEnabled = NO;
    self.designImg.hidden = NO;
    NSString *description = [NSString stringWithFormat:NSLocalizedString(@"notify_list_like", nil), userName];
    if ([designInfo.foldCount integerValue] > 0)
    {
        description = [NSString stringWithFormat:NSLocalizedString(@"notify_list_like_group", nil), userName, designInfo.foldCount];
    }
    NSString *htmlString = [NSString stringWithFormat:@"<span style=\"font-family:-apple-system; font-size:13pt\">%@</span>",description];
    NSData *data = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithData:data
                                                                        options:options
                                                             documentAttributes:nil
                                                                          error:nil];
    self.messageDescription.attributedText = attributeStr;
    [self.designImg loadImageFromUrl:designInfo.resultImage defaultImageName:nil];
}

- (void)setupFollowFromUserName:(NSString *)userName userInfo:(FollowUserInfo *)userInfo
{
    self.followButton.hidden = NO;
    self.followButton.isFollowed = userInfo.isFollowed;
    NSString *description = [NSString stringWithFormat:NSLocalizedString(@"notify_list_follow", nil), userName];
    NSString *htmlString = [NSString stringWithFormat:@"<span style=\"font-family:-apple-system; font-size:13pt\">%@</span>",description];
    NSData *data = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithData:data
                                                                        options:options
                                                             documentAttributes:nil
                                                                          error:nil];
    self.messageDescription.attributedText = attributeStr;
}

- (void)setupFeaturedWithDesignInfo:(NotificationDesignInfoDO *)designInfo
{
    self.avatarProfile.userInteractionEnabled = NO;
    self.designImg.userInteractionEnabled = NO;
    self.designImg.hidden = NO;
    self.avatarProfile.image = nil;

    NSString *description = [NSString stringWithFormat:NSLocalizedString(@"notify_list_feature", nil)];
    NSString *htmlString = [NSString stringWithFormat:@"<span style=\"font-family:-apple-system; font-size:13pt\">%@</span>",description];
    NSData *data = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithData:data
                                                                        options:options
                                                             documentAttributes:nil
                                                                          error:nil];
    self.messageDescription.attributedText = attributeStr;
    self.avatarProfile.image = [UIImage imageNamed:@"system_notification"];
    [self.designImg loadImageFromUrl:designInfo.resultImage defaultImageName:nil];
}

- (void)setupCommentFromUserName:(NSString *)fromUserName designInfo:(NotificationDesignInfoDO *)designInfo
{
    self.designImg.userInteractionEnabled = NO;
    self.designImg.hidden = NO;
    NotificationContentDO *commentInfo = self.detail.noticeContent;
    FollowUserInfo *replyeeInfo = self.detail.replyeeInfo;
    //notify_list_comment_self
    NSString *characterColor = @"<span style='color:#FFCC00'>@</span>";
    NSString *commentFormat = [NSString stringWithFormat:NSLocalizedString(@"notify_list_comment_replyMe", nil), fromUserName, characterColor, commentInfo.content];
    if ([[[UserManager sharedInstance] getLoggedInUserId] isEqualToString:designInfo.designUserId])
    {
        // someone comment on my design
        if (!replyeeInfo)
        {
            commentFormat = [NSString stringWithFormat:@"%@: <br> <b>%@</b>", fromUserName, commentInfo.content];
        }
        else
        {
        	// people reply each other on my design
            if (![[[UserManager sharedInstance] getLoggedInUserId] isEqualToString:replyeeInfo.userId])
            {
                NSString *replyeeUserName = [replyeeInfo getUserFullName];
                commentFormat = [NSString stringWithFormat:@"%@ %@ %@: <br> <b>%@</b>", fromUserName, characterColor, replyeeUserName, commentInfo.content];
            }
        }
    }
    NSString *htmlString = [NSString stringWithFormat:@"<span style=\"font-family:-apple-system; font-size:13pt\">%@</span>",commentFormat];
    NSData *data = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithData:data
                                                                        options:options
                                                             documentAttributes:nil
                                                                          error:nil];
    self.messageDescription.attributedText = attributeStr;
    [self.designImg loadImageFromUrl:designInfo.resultImage defaultImageName:nil];
}

- (UIFont *)setupBoldFont
{
    UIFont *font = [UIFont fontWithName:@".SFUIText-Semibold" size:15];
    return font;
}

- (UIFont *)setupLightFont
{
    UIFont *font = [UIFont fontWithName:@".SFUIText-Light" size:15];
    return font;
}

#pragma mark - actions
- (void)tappedOnAvatar:(UITapGestureRecognizer *)sender {
    if (self.followUserDelegate && [self.followUserDelegate respondsToSelector:@selector(userPressed:)]) {
        [self.followUserDelegate userPressed:self.detail.fromUser];
    }
}

- (void)tappedOnDesignImage:(UITapGestureRecognizer *)sender {
    if ([NSString isNullOrEmpty:self.detail.designInfo.designId])
        return;

    if (self.designItemDelegate && [self.designItemDelegate respondsToSelector:@selector(showDesignDetailById:)]) {
        [self.designItemDelegate showDesignDetailById:self.detail.designInfo.designId];
    }
}

- (IBAction)followPressed:(UIButton *)sender {

    BOOL follow = !self.detail.fromUser.isFollowed;

    __weak typeof(self) weakSelf = self;

    if (self.followUserDelegate && [self.followUserDelegate respondsToSelector:@selector(followUser:follow:preActionBlock:completionBlock:sender:)]) {
        [self.followUserDelegate followUser:self.detail.fromUser
                                     follow:follow
                             preActionBlock:^(NSString * _Nullable userId) {
                                 if (weakSelf != nil && [weakSelf.detail.fromUser.userId isEqualToString:userId]) {
                                     // update follow button state
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         if (weakSelf == nil)
                                             return;

                                         __strong typeof(self) strongSelf = weakSelf;
                                         strongSelf.followButton.isFollowing = YES;
                                         strongSelf.activityIndicator.hidden = NO;
                                         [strongSelf.activityIndicator startAnimating];
                                     });
                                 }
                             }
                            completionBlock:^(NSString * _Nullable userId, BOOL success) {
                                if (weakSelf != nil && [weakSelf.detail.fromUser.userId isEqualToString:userId]) {
                                    // restore follow button state if failed
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if (weakSelf == nil)
                                            return;

                                        __strong typeof(self) strongSelf = weakSelf;
                                        strongSelf.activityIndicator.hidden = YES;
                                        [strongSelf.activityIndicator stopAnimating];
                                        strongSelf.followButton.isFollowing = NO;
                                    });
                                }
                            }
                                     sender:sender];
    }
}

@end
