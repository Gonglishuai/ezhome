//
//  BaseActivityTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//
#import <QuartzCore/QuartzCore.h>
#import "BaseActivityTableCell.h"
#import "ActivityStreamDO.h"
#import "UIImage+SafeFileLoading.h"
#import "UIManager.h"
#import "NotificationNames.h"
#import "HSAnimatingView.h"
#import "ImageFetcher.h"
#import "UILabel+NUI.h"
#import "UIView+Effects.h"
#import "UIView+Alignment.h"



#define VERIFY_FIELD(field) if (field == (NSObject *) [NSNull null]) (field = nil)


@interface BaseActivityTableCell ()

@end


@implementation BaseActivityTableCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedDownloadingImage:) name:@"finishedDownloadingImage" object:nil];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.activityId = nil;
}

#pragma mark - Static

+ (CGFloat)heightForCell
{
    return 400.0;
}

#pragma mark - Public Methods

- (void)setWithData:(ActivityStreamDO *)actDO
{
    self.activityDO = actDO;
    self.type = actDO.activityType;
    
    VERIFY_FIELD(actDO.heartCount);
    self.likeCount = [actDO.heartCount intValue];
    
    VERIFY_FIELD(actDO.commentCount);
    self.commentCount = [actDO.commentCount intValue];
    
    VERIFY_FIELD(actDO.timeStamp);
    self.dateTimestamp = actDO.timeStamp;
    self.timeDescription = [BaseActivityTableCell getSimplefiedTimeStringForDate:self.dateTimestamp];
    
    self.ownerId = actDO.ownerID;
    VERIFY_FIELD(_ownerId);

    self.ownerName = actDO.ownerName;
    VERIFY_FIELD(_ownerName);

    self.ownerImageUrl = actDO.ownerImageURL;
    VERIFY_FIELD(_ownerImageUrl);

    self.actorId = actDO.actorID;
    VERIFY_FIELD(_actorId);

    self.actorName = actDO.actorName;
    VERIFY_FIELD(_actorName);

    self.actorImageUrl = actDO.actorImageURL;
    VERIFY_FIELD(_actorImageUrl);

    self.assetId = actDO.assetID;
    VERIFY_FIELD(_assetId);

    self.assetImageUrl = actDO.assetImageURL;
    VERIFY_FIELD(_assetImageUrl);

    self.assetTitle = actDO.assetTitle;
    VERIFY_FIELD(_assetTitle);

    self.assetText = actDO.assetText;
    VERIFY_FIELD(_assetText);
    
    self.assetType = actDO.assetType;
    
    self.activityId = actDO.Id;
    VERIFY_FIELD(_activityId);
    
    [self refreshUI];
}

- (void)refreshUI
{
    self.myCounter = activityCellInstanceCounter++;
    [self refreshLikeButton];
}

#pragma mark - Image Handling


//This function is only used for when IMAGE_LOADING_SYSTEM == IMAGE_LOADING_SYSTEMV1 (old)
- (NSString *)getImagePathForURL:(NSString *)url
{
    if (self.assetId == nil)
        return [[ConfigManager sharedInstance] getStreamFilePathWithoutExtension:[NSString stringWithFormat:@"activityStream_%@", [url lastPathComponent]]];
    else
        return [[ConfigManager sharedInstance] getStreamFilePathWithoutExtension:[NSString stringWithFormat:@"activityStream_%@_%@" , self.assetId ,[url lastPathComponent]]];
}



- (void)setImageFromURLWithDefaultImage:(NSString *)url forImageView:(UIImageView *)imageView defaultImage:(UIImage *)defaultImage
{
    if (imageView == nil)
    {
        return;
    }
    
    if (url == nil)
    {
        imageView.image = defaultImage;
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
                   {
                       CGSize designSize = imageView.frame.size;
                       NSValue *valSize = [NSValue valueWithCGSize:designSize];
                       NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: url,
                                             IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                                             IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                                             IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : imageView,
                                             IMAGE_FETCHER_INFO_KEY_DEFAULT_IMAGE_URL : defaultImage};
                       
                       NSInteger lastUid = -1;
                       lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                                  {
                                      NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:imageView];
                                      
                                      if (currentUid == uid)
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
                                                             imageView.image = image;
                                                         });
                                      }
                                  }];
                   });
}


- (void)setImageFromURL:(NSString *)url forImageView:(UIImageView *)imageView useSmartfit:(BOOL)smartfit
{
    if (url == nil)
    {
        imageView.image = nil;
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
                   {
                      
                           CGSize designSize = imageView.frame.size;
                           NSValue *valSize = [NSValue valueWithCGSize:designSize];
                           NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: url,
                                                 IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                                                 IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                                                 IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : imageView};
                           
                           if (smartfit == YES)
                           {
                               NSMutableDictionary *tempDic = [dic mutableCopy];
                               [tempDic setObject:[NSNumber numberWithBool:YES] forKey:IMAGE_FETCHER_INFO_KEY_SMARTFIT];
                               dic = tempDic;
                           }
                           
                           NSInteger lastUid = -1;
                           lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                                      {
                                          NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:imageView];
                                          
                                          if (currentUid == uid)
                                          {
                                              dispatch_async(dispatch_get_main_queue(), ^
                                                             {
                                                                 imageView.image = image;
                                                             });
                                          }
                                      }];
                       
                       
                   });
}

- (void)finishedDownloadingImage:(NSNotification *)notification
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^
                   {
                       NSDictionary *info = [notification userInfo];
                       NSNumber *numCounter = [info objectForKey:@"counter"];
                       
                       if ([numCounter integerValue] == self.myCounter)
                       {
                           NSString *path = [info objectForKey:@"path"];
                           UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
                           UIImageView *iv = [info objectForKey:@"imageView"];
                           
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              iv.image = img;
                                          });
                       }
                   });
}

#pragma mark - Utility funcs

+ (NSString *)getSimplefiedTimeStringForDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"MMMM dd"
                                                                         options:0
                                                                          locale:[NSLocale currentLocale]]];
    }
    
    
    NSTimeInterval interval = -[date timeIntervalSinceNow];
    NSString *timestamp = @"";

    if (interval < 0) //error
    {
        timestamp = NSLocalizedString(@"activity_stream_ts_some_time_ago", @"Some time ago");
    }
    else if (interval < 60) //less than a minute
    {
        timestamp = NSLocalizedString(@"activity_stream_ts_just_now", @"Just now");
    }
    else if ((int) floor(interval/60.0) == 1) //exactly one minute
    {
        timestamp = [NSString stringWithFormat:NSLocalizedString(@"activity_stream_1_min_ago", @"1 minute ago")];
    }
    else if (interval < 60*60) //less than an hour
    {
        timestamp = [NSString stringWithFormat:NSLocalizedString(@"activity_stream_ts_mins_ago", @"%d mins ago"), (int) floor(interval/60.0)];
    }
    else if ((int) floor(interval/(60.0*60.0)) == 1) //exactly one hour
    {
        timestamp = [NSString stringWithFormat:NSLocalizedString(@"activity_stream_1_hour_ago", @"1 hour ago")];
    }
    else if (interval < 60*60*24) //less that 24 hours
    {
        timestamp = [NSString stringWithFormat:NSLocalizedString(@"activity_stream_ts_hours_ago", @"%d hours ago"), (int) floor(interval/(60.0*60.0))];
    }
    else if (interval < 60*60*48) //less than 48 hours
    {
        timestamp = NSLocalizedString(@"activity_stream_ts_yesterday", @"Yesterday");
    }
    else //show the exact date
    {
        timestamp = [dateFormatter stringFromDate:date];
    }
    
    return timestamp;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL)isOwnerTheCurrentUser
{
    return [self.ownerId isEqualToString:[[[UserManager sharedInstance]currentUser] userID]];
}

- (BOOL)isActorTheCurrentUser
{
    return [self.actorId isEqualToString:[[[UserManager sharedInstance]currentUser] userID]];
}

- (void)alignHeader
{
    //CGSize sizeThatFits = [self.lblHeader sizeThatFits:CGSizeMake(self.originalHeaderLabelSize.width, self.originalHeaderLabelSize.height)];
    [self.lblHeader setNumberOfLines:3];
    [self.lblHeader sizeToFit];
    [self.lblHeader setFrame:CGRectMake(self.lblHeader.frame.origin.x, self.lblHeader.frame.origin.y, self.originalHeaderLabelSize.width,  self.lblHeader.frame.size.height)];
    [self.lblHeader alignWithView:self.lblIcon type:eAlignmentVerticalCenter];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel*)label didSelectLinkWithURL:(NSURL *)url
{
    
    // The default action for "actor" string is to open the user's profile of actorId
    if ([[url absoluteString] isEqualToString:@"actor"])
    {
        if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openUserProfilePage:)]))
        {
            [self.delegate openUserProfilePage:self.actorId];
        }
    }
    
    // The default action for "design" string is to open the design page with assetId
    else if ([[url absoluteString] isEqualToString:@"design"])
    {

        if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openFullScreen:withType:)]))
        {
            [self.delegate openFullScreen:self.assetId withType:self.assetType];
        }
        
    }
    
    // The default action for "article" string is to open the article page with assetId
    else if ([[url absoluteString] isEqualToString:@"article"])
    {
        if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openFullScreen:withType:)]))
        {
            [self.delegate openFullScreen:self.assetId withType:self.assetType];
        }
    }
    
    // The default action for "owner" is to open the owner's profile
    else if ([[url absoluteString] isEqualToString:@"owner"])
    {
        if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openUserProfilePage:)]))
        {
            [self.delegate openUserProfilePage:self.ownerId];
        }
    }
    
    // The default action for "favorite_proffesionals" is to open the favorite professionals page
    else if ([[url absoluteString] isEqualToString:@"favorite_proffesionals"])
    {
        [[UIMenuManager sharedInstance] professionalsPressed:nil];
    }
    
    // The default action for "favorite_articles" is to open the articles page
    else if ([[url absoluteString] isEqualToString:@"favorite_articles"])
    {
        
        [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamTypeArticles
                                                      andRoomType:@""
                                                        andSortBy:[[UIMenuManager sharedInstance] getSortTypeForDesignStreamType:DesignStreamTypeArticles]];
    }
    
    // The default action for help is to open the compose email to homestyler feedback
    else if ([[url absoluteString] isEqualToString:@"help"])
    {
        if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openHelpEmailPage)]))
        {
            [self.delegate openHelpEmailPage];
        }

    }
    
    // The default action for "help_article" is to open the help article which is defined in the PLIST
    else if ([[url absoluteString] isEqualToString:@"help_article"])
    {
        [[UIManager sharedInstance] openHelpArticle];
    }
}

//
// Sets links and text for a given TTTAttributedLabel
// @parameters: label - TTTAttributedLabel to be set
// text - the text to set for the label
// stringLinksDictionary - A <string> : <linkName> dictionary where <string> is the string to mark as linkable inside text parameter and <linkName> is the name
// of the link as it appears under the delegate TTTAttributedLabelDelegate:attributedLabel:label:didSelectLinkWithURL
// To override the default behaviour of links, ovveride  attributedLabel:label:didSelectLinkWithURL
//
- (void)setAttributedLabelWithTextAndLinksFromDictionary:(TTTAttributedLabel*)label text:(NSString*)text stringLinksDictionary:(NSDictionary*)stringLinksDictionary
{
    label.delegate = self;
    label.text = text;
    
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName,(id)kCTUnderlineStyleAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:(0/255.0) green:(127/255.0) blue:(234/255.0) alpha:1],[NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    label.linkAttributes = linkAttributes;
    
    // Find the ranges for the string to be marked as linkable and associate the link
    for (NSString *key in [stringLinksDictionary allKeys])
    {
        NSRange keyRange = [text rangeOfString:key options:NSBackwardsSearch];
        [label addLinkToURL:[NSURL URLWithString:[stringLinksDictionary objectForKey:key]] withRange:keyRange];
    }
}

- (void)setAttributedLabelWithTextAndLinksFromDictionaryWithSearchDirection:(TTTAttributedLabel*)label text:(NSString*)text stringLinksDictionary:(NSDictionary*)stringLinksDictionary searchDirection:(NSStringCompareOptions)searchDirection
{
    label.delegate = self;
    label.text = text;
    
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName,(id)kCTUnderlineStyleAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:(0/255.0) green:(127/255.0) blue:(234/255.0) alpha:1],[NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    label.linkAttributes = linkAttributes;
    
    // Find the ranges for the string to be marked as linkable and associate the link
    for (NSString *key in [stringLinksDictionary allKeys])
    {
        NSRange keyRange = [text rangeOfString:key options:searchDirection];
        [label addLinkToURL:[NSURL URLWithString:[stringLinksDictionary objectForKey:key]] withRange:keyRange];
    }
}

#pragma mark - Comment Logic

- (void)openCommentPageForCurrentAsset
{
    if (self.assetId == nil)
    {
        return;
    }
    
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openCommentScreenForDesign:withType:)]))
    {
        [self.delegate openCommentScreenForDesign:self.assetId withType:self.assetType];
    }
}

#pragma mark - Like Logic

- (void)likePressed
{
    // check if user is logged in (if not - display the login page without changing the heart state and count)
    if (![self isLoggedIn])
    {
        // this will open the login view if not logged in
        [self.delegate performLikeForItemId:self.assetId withItemType:self.assetType likeState:![self isItemLiked] sender:[self.delegate delegateViewController] shouldUsePushDelegate:NO andCompletionBlock:^(BOOL success)
         {
         }];
        return;
    }

    if (![self isItemLiked] && ![self isButtonLiked]) //we were in unliked state
    {
        [self setButtonLiked:YES];
        [self setLikesCountNumber:[self getLikesCountNumber]+1];
        
        [self performLikeAnimation];
    }
    else if ([self isItemLiked] && [self isButtonLiked]) //we were in liked state
    {
        [self setButtonLiked:NO];
        [self setLikesCountNumber:[self getLikesCountNumber]-1];
    }

    
    [self.delegate performLikeForItemId:self.assetId withItemType:self.assetType likeState:![self isItemLiked] sender:[self.delegate delegateViewController] shouldUsePushDelegate:NO andCompletionBlock:^(BOOL success)
     {
         if (success)
         {
             if (self.activityDO) {
                 self.activityDO.heartCount = [NSString stringWithFormat:@"%d",self.likeCount];
             }
         }
         else
         {
             
         }
         
         [self refreshLikeButton];
     }];
}

#pragma mark - Like Flow

- (BOOL)isLoggedIn
{
    return [[UserManager sharedInstance] isLoggedIn];
}

- (void)setButtonLiked:(BOOL)liked
{
    self.btnLikesLiked.hidden = !liked;
    self.btnLikes.hidden = liked;
}

- (void)setLikesCountNumber:(int)likesCountNum
{
    self.likeCount = likesCountNum;
    self.lblLikesCount.text = [NSString stringWithFormat:@"%d", likesCountNum];
}

- (int)getLikesCountNumber
{
    NSMutableDictionary *likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary;
    LikeDesignDO *likeDO = [likeDict objectForKey:self.assetId];

    if (likeDO) {
        return [likeDO.likesCount intValue];
    }else
        return self.likeCount;

    return 0;
}

- (void)refreshLikeButton
{
    [self setButtonLiked:[self isItemLiked]];
    [self setLikesCountNumber:[self getLikesCountNumber]];
}

- (BOOL)isButtonLiked
{
   return (self.btnLikesLiked.isHidden == NO);
}

- (BOOL)isItemLiked
{
    NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
    LikeDesignDO*  likeDO = [likeDict  objectForKey:self.assetId];
    
    return [likeDO isUserLiked];
}

- (void)likeStatusChanged:(NSNotification *)notificaiton
{
    NSString *itemId = [[notificaiton userInfo] objectForKey:kNotificationKeyItemId];
    
    if ([itemId isEqualToString:self.assetId])
    {
        [self refreshLikeButton];
    }
}

#pragma mark - Like Animation

- (void)performLikeAnimation
{
    return;
}

@end
