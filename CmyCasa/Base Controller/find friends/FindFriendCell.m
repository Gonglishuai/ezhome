//
//  FindFriendCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/7/13.
//
//

#import "FindFriendCell.h"
#import "UserBaseFriendDO.h"
#import "ImageFetcher.h"
#import "UIImageView+ViewMasking.h"
#import "NUIRenderer.h"

@implementation FindFriendCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.fullName.text = @"";
    self.actionButton.hidden = YES;
    self.mfriend = nil;
    
    self.photo.image = [UIImage imageNamed:@"find_friends_profile_image.png"];
    
    if (self.actionButton) {
        [self.actionButton removeFromSuperview];
        self.actionButton = nil;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithFriendData:(UserBaseFriendDO*)bfriend{
    
    self.actionButton = [[HSNUIIconLabelButton alloc]initWithFrame: IS_IPAD? CGRectMake(306, 21, 107, 32) : CGRectMake(192, 65, 112, 30)];
    [self.actionButton addTarget:self action:@selector(activatedAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
    
    [self.photo setMaskToCircleWithBorderWidth:0.0 andColor:[UIColor clearColor]];

    self.mfriend=bfriend;
    self.fullName.text=[bfriend getFullName];
    self.actionButton.userInteractionEnabled=YES;
     self.notHsLabel.hidden=YES;
    self.notHsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"friend_cell_no_account_yet", @""), [ConfigManager getAppName]];

    
    if (self.mfriend.email && [self.mfriend.email isStringValidEmail]==NO) {
        self.actionButton.hidden=YES;
    }else
        self.actionButton.hidden=NO;
    if (bfriend.currentStatus==kFriendNotHomestyler) {
        
        [self.actionButton setTitle:NSLocalizedString(@"friend_action_btn_invite", @"") forState:UIControlStateNormal];
        [self.actionButton setValue:@"FindFriends_ResultCell_InviteButton" forKeyPath:@"nuiClass"];
        [self.actionButton setValue:@"" forKeyPath:@"iconDefaultHexValue"];
        [self.actionButton setValue:@"" forKeyPath:@"iconNuiClass"];
   
        self.notHsLabel.hidden=NO;
        
    }
    if (bfriend.currentStatus==kFriendInvited) {
        [self.actionButton setTitle:NSLocalizedString(@"friend_action_btn_invited", @"") forState:UIControlStateNormal];
        self.actionButton.userInteractionEnabled=NO;
    }
    if (bfriend.currentStatus==kFriendHSNotFollowing) {
        
        [self.actionButton setTitle:NSLocalizedString(@"friend_action_btn_follow", @"") forState:UIControlStateNormal];
        [self.actionButton setValue:@"FindFriends_ResultCell_FollowButton" forKeyPath:@"nuiClass"];
        [self.actionButton setValue:@"" forKeyPath:@"iconDefaultHexValue"];
        [self.actionButton setValue:@"" forKeyPath:@"iconNuiClass"];       
    }
    if (bfriend.currentStatus==kFriendHSFollowing) {
        [self.actionButton setTitle:NSLocalizedString(@"friend_action_btn_unfollow", @"") forState:UIControlStateNormal];
        
        [self.actionButton setValue:@"FindFriends_ResultCell_FollowingButton" forKeyPath:@"nuiClass"];
        [self.actionButton setValue:@"" forKeyPath:@"iconDefaultHexValue"];
        [self.actionButton setValue:@"FindFriends_ResultCell_FollowingIcon" forKeyPath:@"iconNuiClass"];
        
        self.actionButton.userInteractionEnabled=NO;
    }

    if (bfriend.socialFriendType!=kSocialFriendNotSocial || bfriend.picture)
    {
        //load design image
        CGSize designSize = self.photo.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:  (bfriend.picture)?bfriend.picture:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.photo};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.photo];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              if(image)
                                                  self.photo.image = image;

                                          });
                       }
                   }];
    }
    
    [self addSubview:self.actionButton];
}

- (void)activatedAction:(id)sender {

    if (self.delegate && [self.delegate respondsToSelector:@selector(findFriendPerfomAction:)]) {
        [self.delegate findFriendPerfomAction:self.mfriend];
    }
}

- (IBAction)profileImageClicked:(id)sender {
    
    if (self.mfriend.currentStatus==kFriendNotHomestyler
        || self.mfriend.currentStatus==kFriendUnknown
        || self.mfriend.currentStatus==kFriendInvited) {
        return;
    }
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(findFriendProfileClickAction:)]) {
        [self.delegate findFriendProfileClickAction:self.mfriend];
    }
}

@end
