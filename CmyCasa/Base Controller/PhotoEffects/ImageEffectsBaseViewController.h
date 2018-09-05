//
//  ImageEffectsBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 10/10/13.
//
//

#import <UIKit/UIKit.h>





@class HSImageEffectsManager;
@class ProtocolsDef;



typedef enum
{
    ShareScreenModeOpenFromOtherController,
    ShareScreenModeOpenByUser
    
}ShareScreenMode;

#define  EFFECT_THUMB_SIZE 97



@protocol ImageEffectsCellDelegate <NSObject>

-(void)effectAtIndexSelected:(NSInteger)index;


@end


@class  EffectImageViewController;
@class SaveDesignFlowBaseController;

typedef void (^ARshareBackBlock)();
@interface ImageEffectsBaseViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,ImageEffectsCellDelegate,ComeBackArViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *showBeforeAfter;
@property (strong, nonatomic)  UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISwitch *showMyNameSwitch;
@property (strong,nonatomic) NSMutableArray * thumbnailsArray;
@property (strong,nonatomic) UIImage * designBaseImage; //the base image the design started from
@property (strong,nonatomic) UIImage * originalImage;//after user redesigned
@property (strong,nonatomic) UIImage * afterEffectImage; //after applied effects
@property (strong,nonatomic) UIImage * thumbnailOriginalImage;
@property (weak, nonatomic) IBOutlet UIView *collectionViewPlaceholder;
@property (weak, nonatomic) IBOutlet UIImageView *originalImageView;
@property (weak, nonatomic) IBOutlet UIImageView *presentingImage;
@property (nonatomic,strong) NSIndexPath * lastSelectedEffect;
@property (nonatomic ,assign) ShareScreenMode shareScreenMode;
@property (weak, nonatomic) IBOutlet UILabel *lblSwitchTitleAuthorName;
@property (weak, nonatomic) IBOutlet UILabel *lblSwitchTitleInclude;
@property(nonatomic,strong) NSString* designerName;
@property(nonatomic) id<SaveDesignFlowBaseControllerDelegate> delegate;
@property (nonatomic) BOOL isImageEffectsReady;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nextButtonActivityIndicator;
@property (assign,nonatomic)BOOL isMaskLandscape;
@property (copy,nonatomic) ARshareBackBlock backBlock;

- (IBAction)showMyNameAction:(id)sender;
- (IBAction)showBeforeAfterAction:(id)sender;
- (void)refreshPresentingImagesWithMode:(ShareScreenMode)mode;
- (IBAction)skipAction:(id)sender;

- (IBAction)nextAction:(id)sender;
- (void)initCollectionView;
- (void)activateEffects;

@end
