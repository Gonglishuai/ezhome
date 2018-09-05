//
//  ActivityNewArticleTableCell.m
//  Homestyler
//
//  Created by sergei on 12/24/13.
//
//

#import "BaseActivityNewArticleTableCell.h"
#import "UILabel+Size.h"
#import "UIView+Alignment.h"

#define ARTICLE_DEFUALT_DESCRIPTION_LABEL_HEIGHT_IPHONE 58
#define ARTICLE_DEFUALT_DESCRIPTION_LABEL_HEIGHT_IPAD 120

@interface BaseActivityNewArticleTableCell ()

- (IBAction)buttonPressedThumbnail:(id)sender;
- (IBAction)buttonPressedImage:(id)sender;
- (IBAction)buttonPressedArticleTitleOrescription:(id)sender;
- (IBAction)buttonPressedComment:(id)sender;
- (IBAction)buttonPressedLike:(id)sender;

@property (nonatomic) CGRect originalHeaderLabelFrame;

@end


@implementation BaseActivityNewArticleTableCell

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
    self.lblArticleName.text = nil;
    self.lblArticleDescription.text = nil;
    self.lblCommentsCount.text = nil;
    self.lblLikesCount.text = nil;
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
    
    [self.lblArticleName setNumberOfLines:0];
    self.lblHeader.text = [NSString stringWithFormat:ACTIVITY_CELL_TITLE_FORMAT_NEW_ARTICLE, self.assetTitle];
    self.lblArticleAuthor.text = [NSString stringWithFormat:ACTIVITY_CELL_TITLE_FORMAT_NEW_ARTICLE_AUTHOR, self.actorName];
    self.lblTimeDescription.text = self.timeDescription;
    self.lblCommentsCount.text = [NSString stringWithFormat:@"%d", self.commentCount];
    self.lblLikesCount.text = [NSString stringWithFormat:@"%d", self.likeCount];
    self.lblArticleName.text = self.assetTitle;
    self.lblArticleDescription.text = self.assetText;
    
    //the height of the cell is reused so it can't be used this way.
    CGSize size = [self.lblArticleDescription getActualTextHeightForLabel:(IS_IPAD)?ARTICLE_DEFUALT_DESCRIPTION_LABEL_HEIGHT_IPAD:ARTICLE_DEFUALT_DESCRIPTION_LABEL_HEIGHT_IPHONE];//self.lblArticleDescription.frame.size.height];
    
    CGRect articleDescriptionFrame = CGRectMake(self.lblArticleDescription.frame.origin.x,
                                                self.lblArticleDescription.frame.origin.y,
                                                self.lblArticleDescription.frame.size.width,//size.width,
                                                size.height);

    CGRect readMoreFrame = CGRectMake(self.lblReadMore.frame.origin.x,
                                      self.lblArticleDescription.frame.origin.y + size.height,
                                      self.lblReadMore.frame.size.width,
                                      self.lblReadMore.frame.size.height);
    
    [self.lblArticleDescription setFrame:articleDescriptionFrame];
    [self.lblReadMore setFrame:readMoreFrame];
    
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
    
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openUserProfilePage:)]))
    {
        [self.delegate openUserProfilePage:self.ownerId];
    }
}

- (IBAction)buttonPressedImage:(id)sender
{
    [self openArticleFullScreen];
}

- (IBAction)buttonPressedArticleTitleOrescription:(id)sender
{
    [self openArticleFullScreen];
}


- (IBAction)buttonPressedComment:(id)sender
{
    [self openCommentPageForCurrentAsset];
}

- (IBAction)buttonPressedLike:(id)sender
{
    [self likePressed];
}

#pragma mark - UI Supporting

- (void)openArticleFullScreen
{
    if (self.assetId == nil)
    {
        return;
    }
    
    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(openArticleFullScreen:)]))
    {
        [self.delegate openFullScreen:self.assetId withType:self.assetType];
    }
}


@end
