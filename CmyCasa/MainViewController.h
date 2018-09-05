//
//  MainViewController.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SavedDesign.h"
#import "ProtocolsDef.h"
#import "Furniture3DViewController.h"
#import "WarningPopupViewController.h"
#import "ModelsDownloadHandler.h"
#import "UserLoginViewController.h"
#import "DesignsManager.h"
#import "ProductsCatalogViewController_iPad.h"
#import "ProductTagBaseView.h"
#import "ImageOptionsViewController.h"
#import "ImageBackgroundEffectsViewController.h"
#import "UndoHandler.h"
#import "GridOptionsViewController.h"
#import "CatalogMenuLogicManger.h"
#pragma mark- iPhone part
#import "RedesignToolMenuViewController.h"
#import "PaintBaseViewController.h"
#import "ConcealViewController.h"
#import "ImageOptionsDialogView.h"
#import "GridOptionsDialogView.h"
//GAITrackedViewController
@class SaveDesignFlowBaseController;

@interface MainViewController : UIViewController<UserLogInDelegate, DoneNavigationDelegate, Furniture3DViewControllerSelectionDelegate,
                                WarningPopupDelegate, SaveDesignPopupDelegate,
                                ModelsDownloadHandlerDelegate, ProductsCatalogDelegate,UIAlertViewDelegate,ProductTagActionsDelegate, ImageOptionsDelegate, ConcealVCDelegate,GenericWebViewDelegate, ImageBackgroundEffectsDelegate, ImageOptionsDialogViewDelegate,GridOptionsDelegate,GridOptionsDialogViewDelegate>
{
    @private 

	UISlider* brightnessSlider;
    BOOL editingMode;

    ModelsDownloadHandler* _modelsDownloadHandler;
    SaveDesignFlowBaseController*  _saveDesignFlow;
    ProductsCatalogViewController_iPad* _productCatalogView;
    WarningPopupViewController* _warningPopup;
}

@property (strong, nonatomic) GalleryItemDO * originalDesignObject;
@property (strong, nonatomic) GalleryItemDO * originalGalleryItem;
@property (strong, nonatomic) ProductTagBaseView* productTagBaseView;
@property (strong, nonatomic) ImageOptionsDialogView * imageOptionsDialogView;
@property (strong, nonatomic) GridOptionsViewController * gridOptionsViewController;
@property (strong, nonatomic) GridOptionsDialogView * gridOptionsDialogView;
@property (strong, nonatomic) PaintBaseViewController* paintView;
@property (strong, nonatomic) ImageOptionsViewController* imageOptionsView;
@property (strong, nonatomic) Furniture3DViewController* furniture3DViewController;
@property (strong, nonatomic) RedesignToolMenuViewController * iphoneMenuVC;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *iPadTopBar;
@property (weak, nonatomic) IBOutlet UIButton *iphoneCatalogButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *undoView;
@property (weak, nonatomic) IBOutlet UIView *iphoneCatalogButtonView;

@property (strong, nonatomic) UIButton* productInfoButton;
@property (strong, nonatomic) UIView* levitateButton;

@property (weak, nonatomic) UIButton *iphoneShareButton;
@property (weak, nonatomic) UIView *iphoneShareSaveView;

@property (nonatomic) NSString * variationId;
@property (nonatomic) NSString * productId;
@property (nonatomic) NSString * timeStamp;

@property (nonatomic) BOOL currentlyReplacingProduct;
@property (nonatomic) BOOL currentlyDuplicatingProduct;
@property (nonatomic) BOOL shouldGoToRoot;
@property (nonatomic) BOOL alertShowing;
@property (nonatomic) BOOL isLoadedFromCatalogBeforeMainWasActive;
@property (strong, atomic) Entity *entityToReplace;
@property (strong, atomic) Entity *entityToDuplicate;

- (IBAction)backPressed:(id)sender;
- (IBAction)sharePressed:(id)sender;
- (IBAction)catalogPressed:(id)sender;
- (IBAction)paintPressed:(id)sender;
- (IBAction)deletePressed:(id)sender;
- (IBAction)savePressed:(id)sender;
- (IBAction)scalePressed:(id)sender;
- (IBAction)performUndoAction:(id)sender;
- (IBAction)performRedoAction:(id)sender;

- (void)updateBGImage;
- (void)recheckAllModelsAddedToScene;
- (void)catalogPressed ;
- (void)updateUndoRedoStates;
- (void)iphonePaintPressed:(id)sender;
- (void)imageOptionsDialogViewPressed:(id)sender;
- (void)stopEditing;
- (void)variateEntity:(Entity*)entity withVariationId:(NSString*)variationId;


@end
