//
//  ActivityNewFollowerTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "BaseActivityNewFollowerTableCell.h"
#import "UIView+Alignment.h"

@interface BaseActivityNewFollowerTableCell ()

- (IBAction)buttonPressedThumbnail:(id)sender;
- (IBAction)buttonPressedFollow:(id)sender;


@end


@implementation BaseActivityNewFollowerTableCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.ivOwner setMaskToCircleWithBorderWidth:0.0 andColor:[UIColor clearColor]];
    
    // Store the header frame as it is dynamically changed in every reuse and we require it for reset
    self.originalHeaderLabelSize = self.lblHeader.frame.size;

    
    [self cleanFields];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self cleanFields];
}

- (void)cleanFields
{
    self.ivOwner.image = nil;
    self.lblHeader.text = nil;
    self.lblTimeDescription.text = nil;
    [self.btnFollow setHidden:NO];
}

#pragma mark - Static

+ (CGFloat)heightForCell
{
    return 100.0;
}

#pragma mark - Overrides

- (void)refreshUI
{
    [super refreshUI];
    
    [self setImageFromURLWithDefaultImage:self.actorImageUrl forImageView:self.ivOwner defaultImage:[UIImage imageNamed:@"profile_page_image"]];

    if (self.actorId != nil)
    {
        // Test if we should display the follow button to the user
        if ([[HomeManager sharedInstance] isFollowingUser:self.actorId] || [self isActorTheCurrentUser])
            [self.btnFollow setHidden:YES];
        else
            [self.btnFollow setTitle:NSLocalizedString(@"activity_follow_button",@"")
                            forState:UIControlStateNormal];
    }
    
    NSString *headerText = nil;
    if ([self isOwnerTheCurrentUser])
    {
        headerText = [NSString stringWithFormat:self.privateTitleFormat, self.actorName];
        [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblHeader
                                                          text:headerText
                                         stringLinksDictionary:@{self.actorName : @"actor"}];
    }
    /*else if ([self isActorTheCurrentUser])
    {
        headerText = [NSString stringWithFormat:self.privatePublicTitleFormat, self.ownerName];
        [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblHeader
                                                          text:headerText
                                         stringLinksDictionary:@{self.ownerName : @"owner"}];
    }*/
    else
    {
        headerText = [NSString stringWithFormat:self.publicTitleFormat, self.actorName, self.ownerName];
        [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblHeader
                                                          text:headerText
                                         stringLinksDictionary:@{self.actorName : @"actor",
                                                                 self.ownerName : @"owner"}];
    }
    
    self.lblTimeDescription.text = self.timeDescription;
}

#pragma mark - UI Actions

- (IBAction)buttonPressedThumbnail:(id)sender
{
    if (self.actorId == nil)
    {
        return;
    }
    
    //if the actor is myself than do nothing
    NSString *myUserId = [[[UserManager sharedInstance] currentUser] userID];
    if ((myUserId != nil) && (self.actorId != nil) && ([myUserId isEqualToString:self.actorId]))
    {
        return;
    }
    
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openUserProfilePage:)]))
    {
        [self.delegate openUserProfilePage:self.actorId];
    }
}

- (IBAction)buttonPressedTitle:(id)sender
{
    if (self.actorId == nil)
    {
        return;
    }
    
    //if the actor is myself than do nothing
    NSString *myUserId = [[[UserManager sharedInstance] currentUser] userID];
    if ((myUserId != nil) && (self.actorId != nil) && ([myUserId isEqualToString:self.actorId]))
    {
        return;
    }
    
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openUserProfilePage:)]))
    {
        [self.delegate openUserProfilePage:self.actorId];
    }
}

- (IBAction)buttonPressedFollow:(id)sender
{
    // Once the follow button is clicked the button will disappear
    if (![[HomeManager sharedInstance] isFollowingUser:self.actorId])
    {
        if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(followUser:)]))
        {
            FollowUserInfo *userInfo = [FollowUserInfo new];
            userInfo.userId = self.actorId;
            userInfo.type = FollowUserTypeNormal;
            userInfo.photoUrl = self.actorImageUrl;

            [userInfo createSeparateNamesFromFullName:self.actorName];

            [self.delegate followUser:userInfo];
        }
            [self.btnFollow setHidden:YES];
    }
}


@end
