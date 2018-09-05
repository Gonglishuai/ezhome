//
//  ActivityWelcomeTableCell.m
//  Homestyler
//
//  Created by Avihay Assouline on 1/6/14.
//
//

#import "BaseActivityWelcomeTableCell.h"
#import "UILabel+Size.h"
#import "UIView+Alignment.h"

#define POINT_TO_PX(x) (x/2)

@implementation BaseActivityWelcomeTableCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.ivOwner setMaskToCircleWithBorderWidth:0.0 andColor:[UIColor clearColor]];
    
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
    self.lblCommentsCount.text = nil;
    self.lblLikesCount.text = nil;
    self.lblHeartAndComment.text = nil;
    self.lblFavoriteProffesionals.text = nil;
    self.lblFavoriteArticles.text = nil;
    self.lblFollowFriends.text = nil;
    self.lblHelpArticle.text = nil;
    self.lblHelpArticle.text = nil;
}

#pragma mark - Static

+ (CGFloat)heightForCell
{
    return 100.0; //this will be overriden by subclass
}

#pragma mark - Overrides

- (void)refreshUI
{
    [super refreshUI];
    
    if ([ConfigManager isWhiteLabel]) {
        
        self.ivOwner.image = [UIImage imageNamed:@"hsicon57x57"];
        self.lblTitle.text = NSLocalizedString(@"activity_welcome_title_wl", @"");
        self.lblSubtitle.text = NSLocalizedString(@"activity_welcome_subtitle", @"");
        self.lblHeartAndComment.text = [NSString stringWithFormat:NSLocalizedString(@"activity_welcome_heart_and_comment_message_wl", @""), [ConfigManager getAppName]];
        [self.ivFavoriteArticlesIcon setHidden:YES];
        [self.ivFavoriteProfessionalsIcon setHidden:YES];
        self.lblFollowFriends.text = [NSString stringWithFormat:NSLocalizedString(@"activity_welcome_find_and_follow_message_wl", @""), [ConfigManager getAppName]];
        [self.lblHelpArticle setNumberOfLines:0];
        [self setAttributedLabelWithTextAndLinksFromDictionaryWithSearchDirection:self.lblHelpArticle
                                                                             text:NSLocalizedString(@"activity_welcome_help_message", @"")
                                                            stringLinksDictionary:@{NSLocalizedString(@"activity_welcome_help_key", @"") : @"help",
                                                                                    NSLocalizedString(@"activity_welcome_help_article_key", @"") : @"help_article"}
                                                                  searchDirection:NSLiteralSearch];
        self.lblHappyHomestylering.text = NSLocalizedString(@"activity_welcome_happy_homestyling_wl", @"");
    }else{
        self.ivOwner.image = [UIImage imageNamed:@"notification_homstyler_logo.png"];
        self.lblTitle.text = NSLocalizedString(@"activity_welcome_title", @"");
        
        self.lblSubtitle.text = NSLocalizedString(@"activity_welcome_subtitle", @"");
        self.lblHeartAndComment.text = NSLocalizedString(@"activity_welcome_heart_and_comment_message", @"");
        self.lblHappyHomestylering.text = NSLocalizedString(@"activity_welcome_happy_homestyling", @"");
        
        
        [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblFavoriteProffesionals
                                                          text:NSLocalizedString(@"activity_welcome_favorite_proffesionals_message", @"")
                                         stringLinksDictionary:@{NSLocalizedString(@"activity_welcome_favorite_proffesionals_key", @"") : @"favorite_proffesionals"}];
        
        [self setAttributedLabelWithTextAndLinksFromDictionary:self.lblFavoriteArticles
                                                          text:NSLocalizedString(@"activity_welcome_favorite_articles_message", @"")
                                         stringLinksDictionary:@{NSLocalizedString(@"activity_welcome_favorite_articles_key", @"") : @"favorite_articles"}];
        
        self.lblFollowFriends.text = NSLocalizedString(@"activity_welcome_find_and_follow_message", @"");
        
        [self.lblHelpArticle setNumberOfLines:0];
        [self setAttributedLabelWithTextAndLinksFromDictionaryWithSearchDirection:self.lblHelpArticle
                                                                             text:NSLocalizedString(@"activity_welcome_help_message", @"")
                                                            stringLinksDictionary:@{NSLocalizedString(@"activity_welcome_help_key", @"") : @"help",
                                                                                    NSLocalizedString(@"activity_welcome_help_article_key", @"") : @"help_article"}
                                                                  searchDirection:NSLiteralSearch];
    }
}

- (void)arrangeWelcomeMessageWithMargin:(CGFloat)bottomMargin
{
    CGFloat heightDelta = 0;
    
    // Store the bottom Happy Homestylering frame size before any adjustments.
    // It will be used to compare with post adjustments to detect the difference in height sizes
    CGRect prevHappyFrame = self.lblHappyHomestylering.frame;
    
    // The list of UILabel ites the we wish to "Chain" vertically in the welcome message (Order is important)
    NSArray *itemList = @[self.lblHeartAndComment, self.lblFavoriteProffesionals, self.lblFavoriteArticles, self.lblFollowFriends, self.lblHelpArticle];
    
    // The matching icons for each item in the above array (Order is important)
    NSArray *iconList = @[self.ivHeartIcon, self.ivFavoriteProfessionalsIcon, self.ivFavoriteArticlesIcon, self.ivFindFriendsIcon, self.ivHelpIcon];
    
    UIView *prevView = nil;
    NSUInteger i = 0;
    // Iterate the labels in the list and arrange them vertically while keeping a veritcal margin between the items
    for (UILabel *label in itemList)
    {
        // Provide "Unlimited" vertical space to grow
        [label setNumberOfLines:0];
        
        // Size to fit the label. Note: Size to fit will not access the current width so we can use it
        [label sizeToFit];
        
        if (prevView != nil)
            [prevView appendViewWithMargin:label type:eAppendBottom margin:bottomMargin];
        
        // Align the icon view to the middle of the first line on the text =>
        UIView *iconView = (UIView*)[iconList objectAtIndex:i];
        [iconView alignWithViewAndMargin:label type:eAlignmentTop margin:POINT_TO_PX(label.font.pointSize/2)];

        prevView = label;
        i++;
    }
    
    // Append the Happy Homestylering label at the bottom of the last item
    [prevView appendViewWithMargin:self.lblHappyHomestylering type:eAppendBottom margin:bottomMargin];
    
    // Compute the difference in location between pre and post arrangements
    CGRect currentHappyFrame = self.lblHappyHomestylering.frame;
    heightDelta = fabs(currentHappyFrame.origin.y - prevHappyFrame.origin.y);
        
    if (self.iphoneContainerView)
    {
        CGRect iphoneFrame = self.iphoneContainerView.frame;
        [self.iphoneContainerView setFrame:CGRectMake(iphoneFrame.origin.x, iphoneFrame.origin.y, iphoneFrame.size.width, iphoneFrame.size.height + heightDelta)];
    }
    
}

@end
