//
//  ActivityDesignLikedTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "TTTAttributedLabel.h"
#import "BaseActivityDesignLikedTableCell.h"
#import "UIView+Alignment.h"

@interface BaseActivityDesignLikedTableCell ()

- (IBAction)buttonPressedThumbnail:(id)sender;
- (IBAction)buttonPressedImage:(id)sender;
- (IBAction)buttonPressedComment:(id)sender;
- (IBAction)buttonPressedLike:(id)sender;

@property (nonatomic) CGRect originalHeaderLabelFrame;

@end


@implementation BaseActivityDesignLikedTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Store the header frame as it is dynamically changed in every reuse and we require it for reset
    self.originalHeaderLabelFrame = self.lblHeader.frame;
    [self.ivOwner setMaskToCircleWithBorderWidth:0.0 andColor:[UIColor clearColor]];
    self.originalHeaderLabelSize = self.lblHeader.frame.size;

    [self cleanFields];
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
}

#pragma mark - Static

+ (CGFloat)heightForCell
{
    return 100.0; //subcalss will override this
}

#pragma mark - Overrides

- (void)refreshUI
{
    [super refreshUI];
        
    // Display a psuedo aggregated label in case the like count is larger then 1
    
    
    NSDictionary *dicLinks = @{};
    NSString *strHeaderText = nil;
    if ([self.delegate isCurrentCellOfLoggedInUser] && [self isActorTheCurrentUser])
    {
        dicLinks = @{self.assetTitle : @"design"};
        
        if (self.likeCount > 1)
        {
            strHeaderText = [NSString stringWithFormat:self.titlePrivateFormatAgg, [NSNumber numberWithInt:self.likeCount - 1], self.assetTitle];
        }
        else
        {
            strHeaderText = [NSString stringWithFormat:self.titlePrivateFormat, self.assetTitle];
        }
    }
    else
    {
        if (self.actorName && self.assetTitle) {
            dicLinks = @{self.actorName : @"actor",
                         self.assetTitle : @"design"};
        }else{
            dicLinks = @{};
        }
        if (self.likeCount > 1)
        {
            strHeaderText = [NSString stringWithFormat:self.titleFormatAgg, self.actorName, [NSNumber numberWithInt:self.likeCount - 1],self.assetTitle];
        }
        else
        {
            strHeaderText = [NSString stringWithFormat:self.titleFormat, self.actorName, self.assetTitle];
        }
    }
    
    [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblHeader
                                                      text:strHeaderText
                                     stringLinksDictionary:dicLinks];
    
    self.lblTimeDescription.text = self.timeDescription;
    self.lblCommentsCount.text = [NSString stringWithFormat:@"%d", self.commentCount];
    self.lblLikesCount.text = [NSString stringWithFormat:@"%d", self.likeCount];
    
    [self setImageFromURLWithDefaultImage:self.actorImageUrl forImageView:self.ivOwner defaultImage:[UIImage imageNamed:@"profile_page_image"]];
    [self setImageFromURL:self.assetImageUrl forImageView:self.ivDesign useSmartfit:NO];
}

#pragma mark - UI Actions

- (IBAction)buttonPressedThumbnail:(id)sender{
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
        //[self.delegate openUserProfilePage:self.ownerId];
        [self.delegate openUserProfilePage:self.actorId];
    }
}

- (IBAction)buttonPressedImage:(id)sender{
    if (self.assetId == nil)
    {
        return;
    }
    
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openFullScreen:withType:)]))
    {
        [self.delegate openFullScreen:self.assetId withType:self.assetType];
    }
}

- (IBAction)buttonPressedComment:(id)sender{
    [self openCommentPageForCurrentAsset];
}

- (IBAction)buttonPressedLike:(id)sender{
    [self likePressed];
}


@end
