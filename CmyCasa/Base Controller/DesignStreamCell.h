//
//  DesignStreamCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/10/13.
//
//

#import <UIKit/UIKit.h>
#import "ProtocolsDef.h"
#import "GalleryStreamViewController.h"

@class GalleryItemDO;
@class GalleryStreamBaseController;

@interface DesignStreamCell : UITableViewCell

- (void)initCellWithGalleryItem:(GalleryItemDO*)item;
- (void)cellImageUpadewithImage:(UIImage*)image;
- (void)loadUserProfileImageForIndexPath:(NSIndexPath*)path;
- (IBAction)userProfileActionClick:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)likeAction:(id)sender;
- (IBAction)openFullScreenWithComments:(id)sender;
- (void)hideUserProfileImage;

@property (nonatomic)GalleryItemDO* m_item;
@property (nonatomic)NSString * imagePath;
@property (nonatomic)NSString * userImagePath;
@property (nonatomic)NSString * imageURL;
@property (weak, nonatomic) IBOutlet UIImageView *designImage;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *commnetsCount;
@property (weak, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UILabel *authorTitle;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButtonLiked;
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UIImageView *typeIcon;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) id<GalleryStreamViewControllerDelegate, DesignStreamCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIView *userProfilePicView;
@property (nonatomic ,strong)NSString *shareImageUrl;
@property (nonatomic ,strong)NSString *shareImagePath;
@property (weak, nonatomic) IBOutlet UIView *statsContainer;
@end
