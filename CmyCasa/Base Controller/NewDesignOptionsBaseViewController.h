//
//  NewDesignOptionsBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/30/13.
//
//

#import <UIKit/UIKit.h>
#import "UIManager.h"

@class ProtocolsDef;

@interface NewDesignOptionsBaseViewController : UIViewController


- (IBAction)closeOverlay:(id)sender;
- (IBAction)openNewDesignHelp:(id)sender;
- (IBAction)openEmptyRoomsArticles:(id)sender;
- (IBAction)openSampleRoomsArticles:(id)sender;
- (IBAction)cameraPressed:(id)sender;
- (IBAction)devicePressed:(id)sender;
- (IBAction)ARPressed:(id)sender;

- (BOOL)isARAvailable;

@property (nonatomic, assign) id<NewDesignViewControllerDelegate> iPadGalleryDelegate;
@end
