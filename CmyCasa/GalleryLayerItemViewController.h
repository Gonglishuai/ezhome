//
//  GalleryLayerItemViewController.h
//  CmyCasa
//
//  Created by Gil Hadas on 12/31/12.
//
//

#import <UIKit/UIKit.h>
#import "GalleryItemDO.h"
#import "GalleryStreamViewController.h"

@interface GalleryLayerItemViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *bottom_barView;
@property (weak, nonatomic) IBOutlet UIView *bottom_bar_btnsView;
@property (weak, nonatomic) IBOutlet UILabel *comments_lbl;
@property (weak, nonatomic) IBOutlet UILabel *likes_lbl;
@property (weak, nonatomic) IBOutlet UILabel *title_lbl;
@property (nonatomic) NSInteger itemNumber;
@property (weak, nonatomic) IBOutlet UITextView *articleDescription;
@property (weak, nonatomic) IBOutlet UILabel *articleTitle;
@property (weak, nonatomic) IBOutlet UIView *articleSummaryUI;
@property (weak, nonatomic) IBOutlet UIImageView *itemTypeImage;
@property (weak, nonatomic) IBOutlet UIButton *btnComments;
@property (weak, nonatomic) IBOutlet UIButton *btnLikes;
@property (weak, nonatomic) IBOutlet UIButton *btnLikesLiked;
@property (nonatomic, weak) id<GalleryStreamViewControllerDelegate,GalleryImagesDelegate> galleryLayerDelegate;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet UIImageView *galleryImage;
@property (nonatomic) int indexInGalleryLayout;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIView *userProfilePicView;
@property (nonatomic ,strong)NSString *shareImageUrl;
@property (nonatomic ,strong)NSString *shareImagePath;

- (IBAction)shareAction:(id)sender;
- (IBAction)openuserProfile:(id)sender;
- (IBAction)commentsPressed:(id)sender;
- (IBAction)likesPressed:(id)sender;
- (void)adjustSize;
- (void)setItemWithLoadRequest:(DesignBaseClass *)in_item shouldLoad:(BOOL)needLoading;
- (void)preloadGalleryItemImages:(DesignBaseClass *)in_item needLoading:(BOOL)needLoading;
- (void)setItem:(DesignBaseClass*) in_item;
- (void)setImage : (UIImage*) image;
- (void)clearImage;
- (void)updateLikedState;
- (void)clearObservers;
- (void)addObservers;
- (BOOL)likesPressedWithResponseOK:(NSString*)designID;

@end
