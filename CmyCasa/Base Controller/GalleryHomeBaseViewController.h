//
//  GalleryHomeBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 6/3/13.
//
//

#import <UIKit/UIKit.h>
#import <RQShineLabel/RQShineLabel.h>

@class ProtocolsDef;
@class UIImage;
@class remoteDownload;
@class UIManager;

@interface GalleryHomeBaseViewController : UIViewController<NewDesignViewControllerDelegate, UINavigationControllerDelegate,UIAlertViewDelegate, ProductsCatalogDelegate>


- (IBAction)openMenuAction:(id)sender;
- (IBAction)openProfileAction:(id)sender;
- (IBAction)actionStartNewDesign:(id)sender;
- (IBAction)action3DStreamSelected:(id)sender;
- (IBAction)actionCatalogSelected:(id)sender;
- (IBAction)actionHelpSelected:(id)sender;
- (IBAction)contestClickAction:(id)sender;
- (void)updateProfileDetails;
- (BOOL)shouldDisplayLoginScreenOnStart;
- (void)openCatalogFromViewController;
- (void)setOfflineIndicatorAccordingToNetworkStatus;

// animations for home screen first loading
-(void)animateGalleryMenuOptions:(UIView *)menuView;


@property (weak, nonatomic) IBOutlet UIImageView *contestImage;
@property (weak, nonatomic) IBOutlet UILabel *contestTitle;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIView *contestView;
@property (weak, nonatomic) IBOutlet UIImageView *ivProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *ivProfileName;
@property (weak, nonatomic) IBOutlet UIView * downloadingView;
@property (weak, nonatomic) IBOutlet UILabel *lblPrecentage;
@property (weak, nonatomic) IBOutlet UILabel *lblDownLoadPackage;
@property (weak, nonatomic) IBOutlet UIButton *offlineIcon;
@property (strong, nonatomic) RQShineLabel *shineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@end
