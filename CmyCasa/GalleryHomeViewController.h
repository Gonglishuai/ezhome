//
//  GalleryHomeViewController.h
//  CmyCasa
//
//  Created by Gil Hadas.
//
//

#import <UIKit/UIKit.h>
#import "GalleryHomeBaseViewController.h"

@interface GalleryHomeViewController : GalleryHomeBaseViewController<UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *galleryMenuOptionsView;
@property (weak, nonatomic) IBOutlet UIView *animatedLabelContainerView;

@end
