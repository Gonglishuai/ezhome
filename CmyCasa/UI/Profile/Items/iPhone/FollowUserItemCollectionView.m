//
//  FollowUserItemView.m
//  Homestyler
//
//  Created by Yiftach Ringel on 20/06/13.
//
//

#import "FollowUserItemCollectionView.h"
#import "UIImageView+URLLoader.h"
#import "FollowUserInfo.h"

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
    self = [[NSBundle mainBundle] loadNibNamed:@"FollowUserItemView" owner:self options:nil][0];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.containerView.hidden = YES;
}

- (void)setFollowUserInfo:(FollowUserInfo *)followUserInfo
{
    _followUserInfo = followUserInfo;
    
    if (followUserInfo != nil)
    {
        self.containerView.hidden = NO;
        
        // Take the large version of facebook image
        if ([followUserInfo.photoUrl rangeOfString:@"graph.facebook.com/"].location!=NSNotFound &&
            [followUserInfo.photoUrl rangeOfString:@"?type=large"].location==NSNotFound)
        {
            followUserInfo.photoUrl=[NSString stringWithFormat:@"%@?type=large",followUserInfo.photoUrl];
        }
        
        [self.userImage loadImageWithUrl:followUserInfo.photoUrl
                        placeholderImage:[UIImage imageNamed:@"profile_page_image.png"]];
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", followUserInfo.firstName, followUserInfo.lastName];
        [self updateStatus];
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
        NSString* status = self.followUserInfo.isFollowedByLoggedInUser ? NSLocalizedString(@"unfollow", @"unfollow") : NSLocalizedString(@"follow", @"follow");
        self.statusLabel.hidden = NO;
        self.statusLabel.text = status;
        self.followButton.hidden = NO;
        [self.followButton setTitle:status forState:UIControlStateNormal];
        self.followingTickImage.hidden = !self.followUserInfo.isFollowedByLoggedInUser;
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
        [self.delegate followPressed:self.followUserInfo didFollow:!self.followUserInfo.isFollowedByLoggedInUser];
        
        [self updateStatus];
    }
}

@end
