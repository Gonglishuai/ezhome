//
//  AppDelegate.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIManager.h"
#import "SHBaseAppDelegate.h"
//#import "FBSDKCoreKit.h"
//#import "FBSDKShareKit.h"
//#import "FBSDKLoginKit.h"

typedef NS_ENUM(NSInteger, CoTabIndexType)
{
    CoTabIndexTypeHome = 0,
    CoTabIndexTypeCase,
    CoTabIndexTypeBidding,
    CoTabIndexTypeDesigner,
    CoTabIndexTypePersonal,
    CoTabIndexTypeIM,
    CoTabIndexTypeMyProject,
};

@class GalleryBaseViewController;
@interface AppDelegate : SHBaseAppDelegate
{
    @private
    NSTimer* _memUsgaeTimer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) GLKView* glkView;
@property (strong, nonatomic) GLKViewController* glkVC;
@property (strong, nonatomic) GLKTextureLoader* textureLoader;
@property (assign, atomic) BOOL forceHighQualityRender;
@property (assign, atomic) int debugCurrentSelection;

- (void)startLoadingProcess;
- (UIDeviceOrientation )getSavedDesignOrientation;
- (UIDeviceOrientation )getPrevOrientation;
- (void)setDrawableMultisample;
- (void)specialCaseLogin:(NSString *)confVersion completionBlock:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue;

- (void)setReviewEvents:(int)events;
- (void)setReviewDays:(int)days;
- (void)updateReviewEvent;
- (void)updateReviewLogins;
- (void)gotoSJJ;
- (void)gotoDIY;
- (void)clearSJJUserInfo;
- (void)clearDIYUserInfo;
/**
 * 刷新App Tab
 */
- (void)resetTabsWithIndex:(NSInteger)index;
@end
