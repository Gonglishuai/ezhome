//
//  BaseActivityTableCell.h
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import <UIKit/UIKit.h>
#import "ActivityStreamDO.h"
#import "DesignBaseClass.h"
#import "ProfileProtocols.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+ViewMasking.h"

#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_COMMENT               NSLocalizedString(@"activity_design_commented_title_format", @"")
#define PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_COMMENT       NSLocalizedString(@"private_activity_design_commented_title_format", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_COMMENT_IPH           NSLocalizedString(@"activity_design_commented_title_format_iphone", @"")
#define PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_COMMENT_IPH   NSLocalizedString(@"private_activity_design_commented_title_format_iphone", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_FEATURED              NSLocalizedString(@"activity_design_featured_title_format", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_FEATURED_PRIVATE      NSLocalizedString(@"activity_design_featured_title_format_private", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PUBLISHED             NSLocalizedString(@"activity_design_published_title_format", @"")
#define PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PUBLISHED     NSLocalizedString(@"private_activity_design_published_title_format", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PUBLISHED_PRIVATE     NSLocalizedString(@"activity_design_published_title_format_private", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PROFESSIONAL          NSLocalizedString(@"activity_design_published_professional_title_format", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PROFESSIONAL_PRIVATE  NSLocalizedString(@"activity_design_published_professional_title_format_private", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_NEW_ARTICLE                  NSLocalizedString(@"activity_new_article_title_format", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_NEW_ARTICLE_AUTHOR           NSLocalizedString(@"activity_new_article_author_format", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_LIKED                 NSLocalizedString(@"activity_design_liked_title_format", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_LIKED_IPH             NSLocalizedString(@"activity_design_liked_title_format_iphone", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_AGG_LIKED             NSLocalizedString(@"activity_design_liked_aggregated_title_format", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_DESIGN_AGG_LIKED_IPH         NSLocalizedString(@"activity_design_liked_aggregated_title_format_iphone", @"")
#define PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_LIKED         NSLocalizedString(@"private_activity_design_liked_title_format", @"")
#define PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_AGG_LIKED     NSLocalizedString(@"private_activity_design_liked_aggregated_title_format", @"")
#define PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_AGG_LIKED_IPH NSLocalizedString(@"private_activity_design_liked_aggregated_title_format_iphone", @"")
#define PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_LIKED_IPH     NSLocalizedString(@"private_activity_design_liked_title_format", @"")

#define ACTIVITY_CELL_TITLE_FORMAT_PRIVATE_FOLLOWER             NSLocalizedString(@"activity_private_follower_title_format", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_PUBLIC_FOLLOWER              NSLocalizedString(@"activity_public_follower_title_format", @"")
#define PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_PUBLIC_FOLLOWER      NSLocalizedString(@"private_activity_public_follower_title_format", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_PRIVATE_FOLLOWER_IPH         NSLocalizedString(@"activity_private_follower_title_format_iphone", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_PUBLIC_FOLLOWER_IPH          NSLocalizedString(@"activity_public_follower_title_format_iphone", @"")
#define PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_PUBLIC_FOLLOWER_IPH  NSLocalizedString(@"private_activity_public_follower_title_format_iphone", @"")
#define ACTIVITY_CELL_TITLE_FORMAT_PUBLIC_SELF_FOLLOWER         NSLocalizedString(@"activity_public_follower_title_self_action_format", @"")

// iPhone defines for UI
#define ACTIVITY_HEART_ICON_MARGIN_FROM_TEXT                (2)
#define ACTIVITY_COMMENT_TEXT_MARGIN_FROM_HEART_ICON        (5)
#define ACTIVITY_COMMENT_ICON_MARGIN_FROM_COMMENT_TEXT      (4)


static int activityCellInstanceCounter = 0;


@interface BaseActivityTableCell : UITableViewCell <TTTAttributedLabelDelegate>

- (void)setWithData:(ActivityStreamDO *)actDO;
- (void)refreshUI;

+ (CGFloat)heightForCell;

- (void)setImageFromURL:(NSString *)url forImageView:(UIImageView *)imageView useSmartfit:(BOOL)smartfit;
- (void)setImageFromURLWithDefaultImage:(NSString *)url forImageView:(UIImageView *)imageView defaultImage:(UIImage*)defaultImage;
- (void)setAttributedLabelWithTextAndLinksFromDictionary:(TTTAttributedLabel*)label text:(NSString*)text stringLinksDictionary:(NSDictionary*)stringLinksDictionary;
- (void)setAttributedLabelWithTextAndLinksFromDictionaryWithSearchDirection:(TTTAttributedLabel*)label text:(NSString*)text stringLinksDictionary:(NSDictionary*)stringLinksDictionary searchDirection:(NSStringCompareOptions)searchDirection;

- (void)likePressed;
- (void)openCommentPageForCurrentAsset;


// @returns true if the owner of the activity is the current user, False otherwise
- (BOOL)isOwnerTheCurrentUser;

// @returns true if the actor of the activity is the current user, False otherwise
- (BOOL)isActorTheCurrentUser;

- (void)alignHeader;


@property (nonatomic, weak) id<ActivityTableCellDelegate, LikeDesignDelegate, CommentDesignDelegate> delegate;

//data
@property ActivityType type;
@property (nonatomic, strong) ActivityStreamDO * activityDO;
@property (nonatomic, strong) NSString *activityId;
@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *ownerImageUrl;

@property (nonatomic, strong) NSString *actorId;
@property (nonatomic, strong) NSString *actorName;
@property (nonatomic, strong) NSString *actorImageUrl;

@property (nonatomic, strong) NSString *assetId;
@property (nonatomic, strong) NSString *assetImageUrl;
@property (nonatomic, strong) NSString *assetTitle;
@property (nonatomic, strong) NSString *assetText;
@property (nonatomic)         CGSize    originalHeaderLabelSize;;
@property (nonatomic) ItemType assetType;

@property (nonatomic, strong) NSString *timeDescription;
@property int likeCount;
@property int commentCount;

//model
@property int myCounter;
@property (nonatomic, strong) NSDate *dateTimestamp;

//ui
@property (nonatomic, weak) IBOutlet UILabel        *lblCommentsCount;
@property (nonatomic, weak) IBOutlet UILabel        *lblLikesCount;
@property (nonatomic, weak) IBOutlet UIButton       *btnComments;
@property (nonatomic, weak) IBOutlet UIButton       *btnLikes;
@property (weak, nonatomic) IBOutlet UIButton       *btnLikesLiked;
@property (nonatomic, weak) IBOutlet UILabel        *lblIcon;
@property (weak, nonatomic) IBOutlet UIView         *iphoneContainerView;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel         *lblHeader;

@end
