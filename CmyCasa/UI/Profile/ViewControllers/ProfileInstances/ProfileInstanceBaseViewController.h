//
// Created by Berenson Sergei on 12/23/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ProfilePageBaseViewController.h"
#import "ProfileProtocols.h"

@class ProfilePageBaseViewController;


@interface ProfileInstanceBaseViewController : UIViewController <ProfilePageCollectionDelegate,ProfilePageTableViewDelegate>
-(ProfilePageBaseViewController *)getContentVC;
-(void)initContentViewer;
-(instancetype)initWithRect:(CGRect)rect;
-(void)initContent;
-(void)refreshContent;
-(void)insertTableViewHeader:(UIViewController*)headerController;

@property(nonatomic, assign) BOOL isLoggedInUserProfile;
@property(nonatomic, assign) NSInteger originalDataCount ;
@property(nonatomic, assign) BOOL isDataLoaded;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property(nonatomic, strong) ProfilePageBaseViewController * contentViewer;
@end
