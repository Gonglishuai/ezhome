//
//  SaveDesignFlowBaseController.h
//  Homestyler
//
//  Created by Berenson Sergei on 10/13/13.
//
//

#import <UIKit/UIKit.h>
#import "ImageEffectShareBaseViewController.h"
#import "ImageEffectsBaseViewController.h"
#import "SaveDesignBaseViewController.h"

@interface SaveDesignFlowBaseController : UIViewController<SaveDesignFlowBaseControllerDelegate, HSSharingViewControllerDelegate, SaveDesignPopupDelegate, MFMailComposeViewControllerDelegate>

@property(nonatomic,strong)SaveDesignBaseViewController * saveDesignDialog;
@property(nonatomic,strong)ImageEffectsBaseViewController * imageEffectsDialog;
@property(nonatomic,strong)ImageEffectShareBaseViewController * shareDialog;
@property(nonatomic,strong) UIViewController * activeDialog;
@property(nonatomic, weak) id <SaveDesignPopupDelegate> designDelegate;

-(void)moveToDialogAtIndex:(NSInteger)dialogIndex;
-(void)openShareDialog:(ShareScreenMode)mode;
-(void)openSaveDialog;
-(void)closeSaveFlow:(BOOL)animated;
@end
