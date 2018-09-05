//
//  GalleryImageDesignInfoCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/7/13.
//
//

#import "GalleryImageDesignInfoCell.h"
#import "GalleryImageViewController.h"

#import "ProtocolsDef.h"
#import "NotificationNames.h"

#import "DesignBaseClass.h"

#import "NSString+Contains.h"
#import "NSString+FormatNumber.h"
#import "NSString+Time.h"
#import "UIImage+Exif.h"
#import "UIImageView+LoadImage.h"
#import "UIImageView+ViewMasking.h"
#import "UILabel+NUI.h"
#import "UILabel+Size.h"
#import "UIView+ReloadUI.h"

@interface GalleryImageDesignInfoCell () <HSSharingViewControllerDelegate>
@end

@implementation GalleryImageDesignInfoCell
{
    __weak IBOutlet UIImageView *_profileImage;
    __weak IBOutlet UIButton *_profileButton;
    __weak IBOutlet UILabel *_designAuthor;
    __weak IBOutlet UILabel *_lastUpdate;
    __weak IBOutlet UIImageView *_designTagImage;
    __weak IBOutlet UILabel *_designDescription;
    __weak IBOutlet UIButton *_productListButton;
    __weak IBOutlet UIView *_commentsContainer;
    __weak IBOutlet UILabel *_likesCount;
    __weak IBOutlet UILabel *_commentsCount;
    
    __weak IBOutlet NSLayoutConstraint *_designImageAspectConstraint;
    __weak IBOutlet NSLayoutConstraint *_designInfoContainerHeightConstraint;
}


-(void)awakeFromNib {
    [super awakeFromNib];

    [_profileImage setMaskToCircleWithBorderWidth:1.0f andColor:[UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0]];

    UIEdgeInsets capInsets = UIEdgeInsetsMake(24, 30, 24, 12);
    UIImage * bgImage = [[UIImage imageNamed:@"product_list"] resizableImageWithCapInsets:capInsets];
    [_productListButton setBackgroundImage:bgImage forState:UIControlStateNormal];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChanged:) name:kNotificationLikeDesignDOLikeStatusChanged object:nil];
    
    [self reloadUI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)resetUI {
    [super resetUI];

    _profileImage.image = nil;
    _designAuthor.text = @"";

    _designDescription.text = @"";

    _designTagImage.image = nil;
    _designTagImage.hidden = YES;

    [self setLikesCountNumber:0];
    [self setCommentsCountNumber:0];

    _commentsContainer.hidden = NO;
    _commentsCount.hidden = NO;
    _likesCount.hidden = NO;
}

- (void)toggleLikeState {
    int likesCount = [_itemDetail getLikesCountForDesign];
    likesCount += [_itemDetail isUserLikesDesign] ? -1 : 1;
    [self setLikesCountNumber:likesCount];
}

- (void)restoreLikeState {
    [self refreshLikeButton];
}

- (void)refreshCommentsCount {
    [self setCommentsCountNumber:[[_itemDetail getTotalCommentsCount] intValue]];
}

-(void)initData:(DesignBaseClass*)itemDetail
{
    [super initData:itemDetail];
    if (_itemDetail == nil)
        return;
    
    BOOL isFromProfessional = NO;//self.parentTableHolder.isFullScreenFromProfessionals;
    _designDescription.hidden = isFromProfessional;
    _commentsContainer.hidden= isFromProfessional;
    //for stoping infinit loop between prof and its designs
    _profileButton.enabled = !isFromProfessional;

    if (!_itemDetail.isPublicOrPublished) {
        _designTagImage.image = [UIImage imageNamed:@"tag_private"];
        _designTagImage.hidden = NO;
    }
    
    BOOL is3dDesign = (_itemDetail.type == e3DItem);
    
    _designAuthor.text = _itemDetail.author;
    _lastUpdate.text = [_itemDetail.timestamp smartTime];
    
    _designDescription.text = [_itemDetail._description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    BOOL hasDescription = [NSString notEmpty:_designDescription.text];

    CGFloat descHeight = 40;
    if (hasDescription && !_designDescription.hidden) {
        CGSize size = [_designDescription getActualTextHeightForLabel:10000];
        descHeight += (ceil(size.height) + 4/* vert space between title and desc */);
    }
    _designInfoContainerHeightConstraint.constant = descHeight;
    
    _productListButton.hidden = !is3dDesign;
    if (is3dDesign) {
        int count = 0;
        if (_itemDetail.productsCount && ![_itemDetail.productsCount isEqual:[NSNull null]]) {
            count = _itemDetail.productsCount.intValue;
        }
        [_productListButton setTitle:[NSString stringWithFormat:@"%d", count] forState:UIControlStateNormal];
        [_productListButton sizeToFit];
    }
    
    [self setLikesCountNumber:[_itemDetail getLikesCountForDesign]];
    
    [self setCommentsCountNumber:[[_itemDetail getTotalCommentsCount] intValue]];
    
    [self loadUserProfileImage];
}

-(void)loadUserProfileImage{
    _profileImage.image = [UIImage imageNamed:@"user_avatar"];
    NSString* imageUrlStr = _itemDetail.uthumb;
    if ([NSString isNullOrEmpty:imageUrlStr]) {
        return;
    }

    [_profileImage loadImageFromUrl:imageUrlStr defaultImage:nil];
}


#pragma mark - Actions

- (IBAction)showUserProfile:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(showUserProfile:)]) {
        [self.delegate showUserProfile:_itemDetail];
    }
}

- (IBAction)shoppingListPressed:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(showShoppingList:)]) {
        [self.delegate showShoppingList:_itemDetail];
    }
}

- (IBAction)showDesignLikes:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(showDesignLikes:)]) {
        [self.delegate showDesignLikes:_itemDetail];
    }
}


#pragma mark - private methods

- (void)setCommentsCountNumber:(int)commentsCountNum
{
    _commentsCount.text = [NSString stringWithFormat:@"(%@)", [NSString formatNumber:commentsCountNum]];
}

- (void)setLikesCountNumber:(int)likesCountNum
{
    _likesCount.text = [NSString stringWithFormat:@"(%@)", [NSString formatNumber:likesCountNum]];
}

- (void)likeStatusChanged:(NSNotification *)notificaiton
{
    NSString *itemId = [[notificaiton userInfo] objectForKey:kNotificationKeyItemId];
    
    if ([itemId isEqualToString:_itemDetail._id])
    {
        [self refreshLikeButton];
    }
}

- (void)refreshLikeButton
{
    [self setLikesCountNumber:[_itemDetail getLikesCountForDesign]];
    if ([self.delegate respondsToSelector:@selector(updateLikeButtonState)]) {
        [self.delegate updateLikeButtonState];
    }
}

@end
