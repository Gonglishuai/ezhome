//
//  iPadSavedDesignPopup.h
//  CmyCasa
//
//  Created by Dor Alon on 12/31/12.
//
//

#import <UIKit/UIKit.h>

#import "SaveDesignBaseViewController.h"

@interface SavedDesignViewController_iPad : SaveDesignBaseViewController{
    UIPopoverController*  _roomTypesPopover;
}

@property (nonatomic, getter = isAnimationDeployed) BOOL animationDeployed;

@end
