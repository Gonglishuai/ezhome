//
//  ActivityDesignFeaturedTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "BaseActivityDesignFeaturedTableCell.h"
#import "UILabel+Size.h"
#import "UIView+Alignment.h"
#import "UILabel+NUI.h"

@interface BaseActivityDesignFeaturedTableCell ()

- (IBAction)buttonPressedThumbnail:(id)sender;
- (IBAction)buttonPressedImage:(id)sender;
- (IBAction)buttonPressedComment:(id)sender;
- (IBAction)buttonPressedLike:(id)sender;

/* Refresh the UI for a featued activity */
- (void)refreshUIFeatured;

/* Refresh the UI for a publish activity */
- (void)refreshUIPublish;

/* Refresh the UI for a professional activity */
- (void)refreshUIProffesional;


@property (nonatomic) CGRect originalHeaderLabelFrame;

@end

@implementation BaseActivityDesignFeaturedTableCell

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
    return 100.0; //this will be overriden by the subclass
}

- (void)refreshUIFeatured
{
    // Display the featured icon on top of the image
    [self.ivFeatured setHidden:NO];
    [self.ivOwner setHidden:!self.ivFeatured.hidden];
    self.lblIcon.text = @"";
    [self.lblIcon setValue:@"ActivityFeatured_CrownIcon" forKeyPath:@"nuiClass"];
    if ([self.lblIcon respondsToSelector:@selector(applyNUI)])
    {
        [self.lblIcon performSelector:@selector(applyNUI)];
    }

    if (self.assetTitle != nil)
    {
        // Sets the correct label according to who is viewing the profile
        if ([self.delegate isCurrentCellOfLoggedInUser] && [self isOwnerTheCurrentUser])
        {
            [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblHeader
                                                              text:[NSString stringWithFormat:ACTIVITY_CELL_TITLE_FORMAT_DESIGN_FEATURED_PRIVATE, self.assetTitle]
                                             stringLinksDictionary:@{self.assetTitle : @"design"}];
        }
        else
        {
            [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblHeader
                                                              text:[NSString stringWithFormat:ACTIVITY_CELL_TITLE_FORMAT_DESIGN_FEATURED, self.ownerName]
                                             stringLinksDictionary:@{self.ownerName : @"owner"}];
        }
    }
}

- (void)refreshUIProffesional
{
    // Create empty header text NSString variable. This will contain the relevant header format
    NSString *headerText = nil;
    NSDictionary *dicLinks = nil;
    self.lblIcon.text = @"";
    [self.lblIcon setValue:@"ActivityGeneral_ActivityIcon" forKeyPath:@"nuiClass"];
    if ([self.lblIcon respondsToSelector:@selector(applyNUI)])
    {
        [self.lblIcon performSelector:@selector(applyNUI)];
    }

    // Hide the featured icon on top of the image
    [self.ivFeatured setHidden:YES];
    [self.ivOwner setHidden:!self.ivFeatured.hidden];

    if ([self.delegate isCurrentCellOfLoggedInUser] && [self isOwnerTheCurrentUser])
    {
        headerText = [NSString stringWithFormat:ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PROFESSIONAL_PRIVATE];
        dicLinks = @{};
    }
    /*else if ([self isActorTheCurrentUser])
     {
     headerText = [NSString stringWithFormat:PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PUBLISHED, self.assetTitle];
     dicLinks = @{self.assetTitle : @"design"};
     }*/
    else
    {
        headerText = [NSString stringWithFormat:ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PROFESSIONAL, self.actorName, self.assetTitle];
       
        if (self.actorName && self.assetTitle) {
            dicLinks = @{self.actorName : @"actor",
                         self.assetTitle : @"design"};
        }else{
            dicLinks = @{};
        }
       
    }
    
    if (self.assetTitle != nil)
    {
        [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblHeader
                                                          text:headerText
                                         stringLinksDictionary:dicLinks];
    }
    
    [self.lblHeader alignWithView:self.lblIcon type:eAlignmentVerticalCenter];
}

- (void)refreshUIPublish
{
    // Create empty header text NSString variable. This will contain the relevant header format
    NSString *headerText = nil;
    NSDictionary *dicLinks = nil;
    self.lblIcon.text = @"";
    [self.lblIcon setValue:@"ActivityGeneral_ActivityIcon" forKeyPath:@"nuiClass"];
    if ([self.lblIcon respondsToSelector:@selector(applyNUI)])
    {
        [self.lblIcon performSelector:@selector(applyNUI)];
    }

    // Hide the featured icon on top of the image
    [self.ivFeatured setHidden:YES];
    [self.ivOwner setHidden:!self.ivFeatured.hidden];
    
    if ([self.delegate isCurrentCellOfLoggedInUser] && [self isOwnerTheCurrentUser])
    {
        headerText = [NSString stringWithFormat:ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PUBLISHED_PRIVATE];
        dicLinks = @{};
    }
    /*else if ([self isActorTheCurrentUser])
    {
        headerText = [NSString stringWithFormat:PRIVATE_ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PUBLISHED, self.assetTitle];
        dicLinks = @{self.assetTitle : @"design"};
    }*/
    else
    {
        headerText = [NSString stringWithFormat:ACTIVITY_CELL_TITLE_FORMAT_DESIGN_PUBLISHED, self.actorName, self.assetTitle];
        if (self.actorName && self.assetTitle) {
            dicLinks = @{self.actorName : @"actor",
                         self.assetTitle : @"design"};
        }else{
            dicLinks = @{};
        }
    }
    
    if (self.assetTitle != nil)
    {
        [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblHeader
                                                          text:headerText
                                         stringLinksDictionary:dicLinks];
    }
    
    [self.lblHeader alignWithView:self.lblIcon type:eAlignmentVerticalCenter];
}


#pragma mark - Overrides

- (void)refreshUI
{
    [super refreshUI];
    
    
    switch (self.assetType) {
        case e3DItem:
            if(self.type==eActivityPublish)
                [self refreshUIPublish];
            if(self.type==eActivityFeatured)
                [self refreshUIFeatured];
            break;
        case e2DItem:
            [self refreshUIProffesional];
            break;
        case eArticle:
            [self refreshUIFeatured];
            break;
        default:
            break;
    }     
    
    self.lblTimeDescription.text = self.timeDescription;
    self.lblCommentsCount.text = [NSString stringWithFormat:@"%d", self.commentCount];
    self.lblLikesCount.text = [NSString stringWithFormat:@"%d", self.likeCount];
    
    // Load images
    [self setImageFromURLWithDefaultImage:self.ownerImageUrl forImageView:self.ivOwner defaultImage:[UIImage imageNamed:@"profile_page_image"]];
    [self setImageFromURL:self.assetImageUrl forImageView:self.ivDesign useSmartfit:NO];
}

#pragma mark - UI Actions

- (IBAction)buttonPressedThumbnail:(id)sender
{
    if (self.ownerId == nil)
    {
        return;
    }
    
    //if the owner is myself than do nothing
    if ([self isOwnerTheCurrentUser])
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


@end
