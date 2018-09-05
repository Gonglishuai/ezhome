//
//  FollowUserItemCollectionView.m
//  Homestyler
//
//  Created by Yiftach Ringel on 20/06/13.
//
//

#import "FollowUserItemCollectionView.h"
#import "FollowUserInfo.h"
#import "ImageFetcher.h"
#import "UIView+Effects.h"
@interface FollowUserItemCollectionView ()

- (IBAction)userPressed;
- (IBAction)followPressed;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *followingTickImage;

@end

@implementation FollowUserItemCollectionView

- (id)init
{
    self = [[NSBundle mainBundle] loadNibNamed:@"FollowUserItemCollectionView" owner:self options:nil][0];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.containerView.hidden = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.containerView.hidden = YES;
    self.userImage.image = [UIImage imageNamed:@"user_avatar"];
}

- (void)setFollowUserInfo:(FollowUserInfo *)followUserInfo
{
    _followUserInfo = followUserInfo;
    [self.userImage setImage:[UIImage imageNamed:@"user_avatar"]];
    if (followUserInfo != nil)
    {
        self.containerView.hidden = NO;
        
        // Take the large version of facebook image
        if ([followUserInfo.photoUrl rangeOfString:@"graph.facebook.com/"].location!=NSNotFound &&
            [followUserInfo.photoUrl rangeOfString:@"?type=large"].location==NSNotFound)
        {
            followUserInfo.photoUrl=[NSString stringWithFormat:@"%@?type=large",followUserInfo.photoUrl];
        }
        
        CGSize designSize = self.userImage.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (followUserInfo.photoUrl)?followUserInfo.photoUrl:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : _userImage};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:_userImage];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              if (image != nil)
                                              {
                                                  _userImage.image = image;
                                              }
                                              else
                                              {
                                                  _userImage.image = [UIImage imageNamed:@"user_avatar"];
                                              }
                                          });
                       }
                   }];
        
        self.nameLabel.text = [followUserInfo getUserFullName];//[NSString stringWithFormat:@"%@ %@", followUserInfo.firstName, followUserInfo.lastName];
        [self updateStatus];
        [self.containerView strokeWithWidth:1.0 cornerRadius:0.0 color:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
    }
    else
    {
        self.containerView.hidden = YES;
    }
}

- (void)updateStatus
{
    // Current user - hide follow status
    if ([self.followUserInfo.userId isEqual:[[[UserManager sharedInstance] currentUser] userID]])
    {
        self.statusLabel.hidden = YES;
        self.followButton.hidden = YES;
        self.followingTickImage.hidden = YES;
    }
    else
    {
        NSString* status = self.followUserInfo.isFollowed ? NSLocalizedString(@"unfollow", @"unfollow") : NSLocalizedString(@"follow", @"follow");
        self.statusLabel.hidden = NO;
        self.statusLabel.text = status;
        self.followButton.hidden = NO;
        [self.followButton setTitle:status forState:UIControlStateNormal];
        self.followingTickImage.hidden = !self.followUserInfo.isFollowed;
    }
}

- (IBAction)userPressed
{
    [self.delegate userPressed:self.followUserInfo];
}

- (IBAction)followPressed
{//TODO: Ariel
    
    // When pressing on the follow from followers the login menu don't popup

    // Check that it's not current user
    if (![self.followUserInfo.userId isEqual:[[[UserManager sharedInstance] currentUser] userID]])
    {
        [self.delegate followPressed:self.followUserInfo didFollow:!self.followUserInfo.isFollowed];
        
        [self updateStatus];
    }
}

#pragma mark - ProfileCellUnifiedInitDelegate
- (void)initWithData:(id)data andDelegate:(id)delegate andProfileUserType:(ProfileUserType)profileType{
    self.followUserInfo = data;
    self.delegate = delegate;
}
@end
