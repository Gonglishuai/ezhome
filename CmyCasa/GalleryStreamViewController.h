//
//  GalleryStreamViewController.h
//  CmyCasa
//
//  Created by Berenson Sergei on 2/11/13.
//
//

#import <UIKit/UIKit.h>
#import "GalleryStreamBaseController.h"
#import "StreamTemplateView.h"
#import "UIView+ReloadUI.h"

@interface GalleryStreamViewController : GalleryStreamBaseController < UIPopoverControllerDelegate>

@property (nonatomic, strong) NSMutableArray * streamTemplates;

- (IBAction)scrollToTop:(id)sender;
- (void)refreshDataStream;
- (StreamTemplateView*)dequeueStreamTemplateForLayout:(GalleryLayoutDO*)layout;

@end
