//
//  ImageEffectShareBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 10/14/13.
//
//

#import <UIKit/UIKit.h>

#import "HSSharingViewController.h"
#include "ProtocolsDef.h"

@interface ImageEffectShareBaseViewController : HSSharingViewController<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) id<SaveDesignFlowBaseControllerDelegate> saveDesignFlowDelegate;
@property (weak, nonatomic) id<ComeBackArViewControllerDelegate> arDelegate;
@property (weak, nonatomic) IBOutlet UILabel *lblShareDesignTitle;

- (IBAction)skipAction:(id)sender;
- (IBAction)backAction:(id)sender;
@end
